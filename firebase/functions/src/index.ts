import * as admin from "firebase-admin";
import {onDocumentCreated, onDocumentWritten} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ═══════════════════════════════════════════════════════════════════════════════
// Helper: Send FCM notification to all parents in a family
// ═══════════════════════════════════════════════════════════════════════════════

interface FamilyDoc {
  parentIds?: string[];
  childIds?: string[];
  name?: string;
}

interface UserDoc {
  fcmToken?: string;
  displayName?: string;
}

/**
 * Looks up all parent FCM tokens for a given familyId and sends
 * a notification to each one.
 */
async function sendToParents(
  familyId: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  try {
    const familySnap = await db.collection("families").doc(familyId).get();
    if (!familySnap.exists) {
      logger.warn(`Family ${familyId} not found`);
      return;
    }

    const family = familySnap.data() as FamilyDoc;
    const parentIds = family.parentIds ?? [];

    if (parentIds.length === 0) {
      logger.info(`No parents in family ${familyId}`);
      return;
    }

    // Fetch FCM tokens for all parents
    const tokenPromises = parentIds.map(async (parentId) => {
      const userSnap = await db.collection("users").doc(parentId).get();
      if (!userSnap.exists) return null;
      const user = userSnap.data() as UserDoc;
      return user.fcmToken ?? null;
    });

    const tokens = (await Promise.all(tokenPromises)).filter(
      (t): t is string => t !== null && t.length > 0
    );

    if (tokens.length === 0) {
      logger.info(`No FCM tokens found for parents in family ${familyId}`);
      return;
    }

    // Send notifications
    const sendPromises = tokens.map((token) =>
      messaging.send({
        token,
        notification: {title, body},
        data: data ?? {},
        android: {
          priority: "high",
          notification: {
            channelId: "studyguardian_alerts",
            sound: "default",
          },
        },
      })
    );

    const results = await Promise.allSettled(sendPromises);
    const succeeded = results.filter((r) => r.status === "fulfilled").length;
    const failed = results.filter((r) => r.status === "rejected").length;
    logger.info(
      `Sent ${succeeded} notifications, ${failed} failed for family ${familyId}`
    );
  } catch (error) {
    logger.error("Error sending notifications to parents:", error);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 1. onNewUsageData — Notify parents when new usage data is synced
// ═══════════════════════════════════════════════════════════════════════════════

export const onNewUsageData = onDocumentCreated(
  "families/{familyId}/usage/{usageId}",
  async (event) => {
    const familyId = event.params.familyId;
    const data = event.data?.data();

    if (!data) {
      logger.warn("No data in usage document");
      return;
    }

    const totalScreenTime = data.totalScreenTime as number ?? 0;
    const hours = Math.floor(totalScreenTime / 60);
    const minutes = totalScreenTime % 60;
    const timeStr = hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;

    await sendToParents(
      familyId,
      "📊 New Usage Data",
      `Screen time today: ${timeStr}`,
      {type: "usage_update", familyId}
    );
  }
);

// ═══════════════════════════════════════════════════════════════════════════════
// 2. onHighDistractionAlert — Alert parents for high distraction scores
// ═══════════════════════════════════════════════════════════════════════════════

export const onHighDistractionAlert = onDocumentWritten(
  "families/{familyId}/analytics/{analyticsId}",
  async (event) => {
    const familyId = event.params.familyId;
    const afterData = event.data?.after?.data();

    if (!afterData) return;

    const distractionScore = afterData.distractionScore as number ?? 0;

    if (distractionScore > 70) {
      const deviceId = afterData.deviceId as string ?? "unknown";

      await sendToParents(
        familyId,
        "⚠️ High Distraction Alert",
        `Distraction score is ${distractionScore}/100 on device ${deviceId.substring(0, 8)}. Consider checking in.`,
        {type: "distraction_alert", familyId, deviceId}
      );
    }
  }
);

// ═══════════════════════════════════════════════════════════════════════════════
// 3. onNewDeviceRegistered — Notify parents when a new device joins
// ═══════════════════════════════════════════════════════════════════════════════

export const onNewDeviceRegistered = onDocumentCreated(
  "families/{familyId}/devices/{deviceId}",
  async (event) => {
    const familyId = event.params.familyId;
    const data = event.data?.data();

    const deviceName = data?.deviceName as string ?? "New Device";
    const manufacturer = data?.manufacturer as string ?? "";

    await sendToParents(
      familyId,
      "📱 New Device Registered",
      `${manufacturer} ${deviceName} has been added to your family.`,
      {type: "device_registered", familyId}
    );
  }
);

// ═══════════════════════════════════════════════════════════════════════════════
// 4. generateScheduledReport — Daily report generation at midnight UTC
// ═══════════════════════════════════════════════════════════════════════════════

export const generateScheduledReport = onSchedule(
  {
    schedule: "0 0 * * *", // Every day at midnight UTC
    timeZone: "UTC",
  },
  async () => {
    logger.info("Starting scheduled daily report generation");

    try {
      const familiesSnap = await db.collection("families").get();

      for (const familyDoc of familiesSnap.docs) {
        const family = familyDoc.data() as FamilyDoc;
        const familyId = familyDoc.id;

        // Get all devices in this family
        const devicesSnap = await db
          .collection("families")
          .doc(familyId)
          .collection("devices")
          .get();

        for (const deviceDoc of devicesSnap.docs) {
          const deviceId = deviceDoc.id;
          const now = new Date();
          const yesterday = new Date(now);
          yesterday.setDate(yesterday.getDate() - 1);

          // Create a daily report document
          const reportId = `${deviceId}_${yesterday.toISOString().split("T")[0]}`;

          const reportData = {
            deviceId,
            type: "daily",
            startDate: admin.firestore.Timestamp.fromDate(yesterday),
            endDate: admin.firestore.Timestamp.fromDate(yesterday),
            generatedAt: admin.firestore.FieldValue.serverTimestamp(),
            data: {
              // Placeholder — in production, aggregate from analytics subcollection
              studyScore: 0,
              focusScore: 0,
              distractionScore: 0,
              productivityPercent: 0,
              totalScreenTime: 0,
              studyHours: 0,
              entertainmentHours: 0,
              educationTime: 0,
              socialMediaTime: 0,
              gameTime: 0,
              topApps: [],
              summary: "Report auto-generated. Data pending sync.",
            },
          };

          await db.collection("reports").doc(reportId).set(reportData);
          logger.info(
            `Generated report ${reportId} for device ${deviceId} in family ${familyId}`
          );
        }

        // Notify parents
        await sendToParents(
          familyId,
          "📋 Daily Report Ready",
          `Your child's daily report for ${family.name ?? "your family"} is ready to view.`,
          {type: "daily_report", familyId}
        );
      }

      logger.info("Scheduled report generation complete");
    } catch (error) {
      logger.error("Error generating scheduled reports:", error);
    }
  }
);
