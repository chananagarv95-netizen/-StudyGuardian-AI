import '../models/app_category.dart';

/// Classifies Android applications into [AppCategory] values based on
/// package name or app name heuristics.
///
/// Contains an extensive lookup table of 200+ known package names mapped to
/// their categories, with fallback keyword-based classification for unknown apps.
class AppClassifier {
  AppClassifier._();

  /// Static lookup map of known Android package names to their categories.
  ///
  /// This map is consulted first during classification for an O(1) exact match.
  static const Map<String, AppCategory> _knownApps = {
    // ─────────────────────────────────────────────────────────────────────────
    // Education (30+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.khanacademy.android': AppCategory.education,
    'com.duolingo': AppCategory.education,
    'com.google.android.apps.classroom': AppCategory.education,
    'org.coursera.android': AppCategory.education,
    'com.udemy.android': AppCategory.education,
    'com.byjus': AppCategory.education,
    'com.byjus.thelearningapp': AppCategory.education,
    'com.unacademy.student': AppCategory.education,
    'com.unacademy.anotherone': AppCategory.education,
    'com.vedantu': AppCategory.education,
    'com.meritnation': AppCategory.education,
    'com.toppr': AppCategory.education,
    'com.brainly': AppCategory.education,
    'com.brainly.android': AppCategory.education,
    'com.quizlet.quizletandroid': AppCategory.education,
    'com.chegg.android': AppCategory.education,
    'org.khanacademy.learnstorm': AppCategory.education,
    'com.photomath.camera': AppCategory.education,
    'com.wolfram.android.alpha': AppCategory.education,
    'com.socratic.android': AppCategory.education,
    'com.grammarly.android.keyboard': AppCategory.education,
    'com.google.android.apps.books': AppCategory.education,
    'com.amazon.kindle': AppCategory.education,
    'in.co.extramarks': AppCategory.education,
    'com.evernote': AppCategory.education,
    'com.microsoft.onenote': AppCategory.education,
    'com.cbs.studyabroadfree': AppCategory.education,
    'com.doubtnut.app': AppCategory.education,
    'com.allen.onlinetest': AppCategory.education,
    'com.testbook.tbapp': AppCategory.education,
    'com.adda247': AppCategory.education,
    'com.codechef.ccapp': AppCategory.education,

    // ─────────────────────────────────────────────────────────────────────────
    // Games (30+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.mojang.minecraftpe': AppCategory.games,
    'com.pubg.krmobile': AppCategory.games,
    'com.tencent.ig': AppCategory.games,
    'com.dts.freefireth': AppCategory.games,
    'com.garena.game.kgid': AppCategory.games,
    'com.supercell.clashroyale': AppCategory.games,
    'com.supercell.clashofclans': AppCategory.games,
    'com.supercell.brawlstars': AppCategory.games,
    'com.kiloo.subwaysurf': AppCategory.games,
    'com.king.candycrushsaga': AppCategory.games,
    'com.king.candycrush': AppCategory.games,
    'com.imangi.templerun2': AppCategory.games,
    'com.halfbrick.fruitninjafree': AppCategory.games,
    'com.rovio.angrybirds': AppCategory.games,
    'com.gameloft.android.ANMP.GloftA9HM': AppCategory.games,
    'com.activision.callofduty.shooter': AppCategory.games,
    'com.ea.game.fifa6_row': AppCategory.games,
    'com.epicgames.fortnite': AppCategory.games,
    'com.roblox.client': AppCategory.games,
    'com.innersloth.spacemafia': AppCategory.games,
    'com.nekki.shadowfight3': AppCategory.games,
    'com.miniclip.eightballpool': AppCategory.games,
    'io.supercent.knifemaster': AppCategory.games,
    'com.outfit7.talkingtomgoldrun': AppCategory.games,
    'com.ludo.king': AppCategory.games,
    'com.budgestudios.googleplay.SHIMMERandSHINESMOOTHIE': AppCategory.games,
    'com.gametion.carrom': AppCategory.games,
    'com.etermax.preguntados.lite': AppCategory.games,
    'com.turn10.asphalt9': AppCategory.games,
    'com.nianticlabs.pokemongo': AppCategory.games,

    // ─────────────────────────────────────────────────────────────────────────
    // Entertainment (25+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.google.android.youtube': AppCategory.entertainment,
    'com.google.android.apps.youtube.creator': AppCategory.entertainment,
    'com.google.android.youtube.tv': AppCategory.entertainment,
    'com.google.android.apps.youtube.music': AppCategory.entertainment,
    'com.netflix.mediaclient': AppCategory.entertainment,
    'com.amazon.avod.thirdpartyclient': AppCategory.entertainment,
    'com.disney.disneyplus': AppCategory.entertainment,
    'com.disney.stream': AppCategory.entertainment,
    'com.spotify.music': AppCategory.entertainment,
    'com.apple.android.music': AppCategory.entertainment,
    'com.jio.media.jiobeats': AppCategory.entertainment,
    'com.bsbportal.music': AppCategory.entertainment,
    'com.gaana': AppCategory.entertainment,
    'com.wynk.music': AppCategory.entertainment,
    'tv.twitch.android.app': AppCategory.entertainment,
    'com.voot.android': AppCategory.entertainment,
    'com.sonyliv': AppCategory.entertainment,
    'com.jio.jioplay.tv': AppCategory.entertainment,
    'com.erosnow': AppCategory.entertainment,
    'com.hungama.myplay': AppCategory.entertainment,
    'com.mxtech.videoplayer.ad': AppCategory.entertainment,
    'com.mxtech.videoplayer.pro': AppCategory.entertainment,
    'com.vlc.android': AppCategory.entertainment,
    'in.startv.hotstar': AppCategory.entertainment,
    'com.zee5.hidevd': AppCategory.entertainment,
    'com.balaji.alt': AppCategory.entertainment,
    'com.aha.video': AppCategory.entertainment,
    'com.sun.nxt': AppCategory.entertainment,

    // ─────────────────────────────────────────────────────────────────────────
    // Social Media (20+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.instagram.android': AppCategory.socialMedia,
    'com.instagram.lite': AppCategory.socialMedia,
    'com.snapchat.android': AppCategory.socialMedia,
    'com.zhiliaoapp.musically': AppCategory.socialMedia,
    'com.ss.android.ugc.trill': AppCategory.socialMedia,
    'com.facebook.katana': AppCategory.socialMedia,
    'com.facebook.lite': AppCategory.socialMedia,
    'com.twitter.android': AppCategory.socialMedia,
    'com.reddit.frontpage': AppCategory.socialMedia,
    'com.tumblr': AppCategory.socialMedia,
    'com.pinterest': AppCategory.socialMedia,
    'in.mohalla.sharechat': AppCategory.socialMedia,
    'com.roposo.android': AppCategory.socialMedia,
    'com.kustom.moj': AppCategory.socialMedia,
    'com.bigo.live': AppCategory.socialMedia,
    'com.helo': AppCategory.socialMedia,
    'com.linkedin.android': AppCategory.socialMedia,
    'com.quora.android': AppCategory.socialMedia,
    'com.kwai.video': AppCategory.socialMedia,
    'com.likee.video': AppCategory.socialMedia,

    // ─────────────────────────────────────────────────────────────────────────
    // Communication (20+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.whatsapp': AppCategory.communication,
    'com.whatsapp.w4b': AppCategory.communication,
    'org.telegram.messenger': AppCategory.communication,
    'org.thoughtcrime.securesms': AppCategory.communication,
    'com.discord': AppCategory.communication,
    'us.zoom.videomeetings': AppCategory.communication,
    'com.google.android.apps.meetings': AppCategory.communication,
    'com.google.android.apps.tachyon': AppCategory.communication,
    'com.microsoft.teams': AppCategory.communication,
    'com.Slack': AppCategory.communication,
    'com.skype.raider': AppCategory.communication,
    'com.viber.voip': AppCategory.communication,
    'com.imo.android.imoim': AppCategory.communication,
    'com.truecaller': AppCategory.communication,
    'com.nll.cb': AppCategory.communication,
    'com.google.android.apps.messaging': AppCategory.communication,
    'com.facebook.orca': AppCategory.communication,
    'com.facebook.mlite': AppCategory.communication,
    'org.jitsi.meet': AppCategory.communication,

    // ─────────────────────────────────────────────────────────────────────────
    // Productivity (20+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.google.android.apps.docs': AppCategory.productivity,
    'com.google.android.apps.docs.editors.sheets': AppCategory.productivity,
    'com.google.android.apps.docs.editors.slides': AppCategory.productivity,
    'com.google.android.apps.docs.editors.docs': AppCategory.productivity,
    'com.microsoft.office.word': AppCategory.productivity,
    'com.microsoft.office.excel': AppCategory.productivity,
    'com.microsoft.office.powerpoint': AppCategory.productivity,
    'com.microsoft.office.onenote': AppCategory.productivity,
    'com.microsoft.office.officehubrow': AppCategory.productivity,
    'com.notion.id': AppCategory.productivity,
    'com.todoist': AppCategory.productivity,
    'com.ticktick.task': AppCategory.productivity,
    'com.anydo': AppCategory.productivity,
    'org.tasks.android': AppCategory.productivity,
    'com.google.android.keep': AppCategory.productivity,
    'com.google.android.calendar': AppCategory.productivity,
    'com.google.android.deskclock': AppCategory.productivity,
    'com.google.android.apps.tasks': AppCategory.productivity,
    'com.asana.app': AppCategory.productivity,
    'com.trello': AppCategory.productivity,

    // ─────────────────────────────────────────────────────────────────────────
    // Shopping (15+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.amazon.mShop.android.shopping': AppCategory.shopping,
    'com.flipkart.android': AppCategory.shopping,
    'com.myntra.android': AppCategory.shopping,
    'com.snapdeal.main': AppCategory.shopping,
    'club.cred': AppCategory.shopping,
    'com.ajio.retail': AppCategory.shopping,
    'in.amazon.mShop.android.shopping': AppCategory.shopping,
    'com.meesho.supply': AppCategory.shopping,
    'com.alibaba.aliexpresshd': AppCategory.shopping,
    'com.shopclues.android': AppCategory.shopping,
    'com.paytmmall': AppCategory.shopping,
    'com.junglee.amazonbuyershoppingapp': AppCategory.shopping,
    'org.nativescript.NativeScriptShopifyApp': AppCategory.shopping,
    'com.ebay.mobile': AppCategory.shopping,
    'com.nykaa.app': AppCategory.shopping,

    // ─────────────────────────────────────────────────────────────────────────
    // Finance (15+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'net.one97.paytm': AppCategory.finance,
    'com.phonepe.app': AppCategory.finance,
    'com.google.android.apps.nbu.paisa.user': AppCategory.finance,
    'in.org.npci.upiapp': AppCategory.finance,
    'com.csam.icici.bank.imobile': AppCategory.finance,
    'com.sbi.SBIFreedomPlus': AppCategory.finance,
    'com.axis.mobile': AppCategory.finance,
    'in.Amazon.mShop.android.shopping': AppCategory.finance,
    'com.mobikwik_new': AppCategory.finance,
    'com.freecharge.android': AppCategory.finance,
    'com.paytm.pgateway': AppCategory.finance,
    'com.bajajfinserv': AppCategory.finance,
    'com.groww.android': AppCategory.finance,
    'com.zerodha.kite3': AppCategory.finance,
    'in.paytm.merchant': AppCategory.finance,

    // ─────────────────────────────────────────────────────────────────────────
    // AI (10+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.openai.chatgpt': AppCategory.ai,
    'com.google.android.apps.bard': AppCategory.ai,
    'com.anthropic.claude': AppCategory.ai,
    'com.microsoft.bing': AppCategory.ai,
    'com.perplexity.ask': AppCategory.ai,
    'com.character.ai': AppCategory.ai,
    'com.jasper.chat': AppCategory.ai,
    'ai.replika.app': AppCategory.ai,
    'com.writesonic.app': AppCategory.ai,
    'com.copy.ai': AppCategory.ai,

    // ─────────────────────────────────────────────────────────────────────────
    // System (20+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.android.settings': AppCategory.system,
    'com.android.phone': AppCategory.system,
    'com.android.contacts': AppCategory.system,
    'com.android.camera': AppCategory.system,
    'com.android.camera2': AppCategory.system,
    'com.android.deskclock': AppCategory.system,
    'com.android.calculator2': AppCategory.system,
    'com.android.vending': AppCategory.system,
    'com.google.android.gms': AppCategory.system,
    'com.google.android.gsf': AppCategory.system,
    'com.android.providers.media': AppCategory.system,
    'com.android.systemui': AppCategory.system,
    'com.android.launcher': AppCategory.system,
    'com.android.launcher3': AppCategory.system,
    'com.google.android.apps.nexuslauncher': AppCategory.system,
    'com.samsung.android.launcher': AppCategory.system,
    'com.miui.home': AppCategory.system,
    'com.android.inputmethod.latin': AppCategory.system,
    'com.google.android.inputmethod.latin': AppCategory.system,
    'com.samsung.android.incallui': AppCategory.system,

    // ─────────────────────────────────────────────────────────────────────────
    // Utilities (15+ entries)
    // ─────────────────────────────────────────────────────────────────────────
    'com.android.chrome': AppCategory.utilities,
    'org.mozilla.firefox': AppCategory.utilities,
    'com.opera.browser': AppCategory.utilities,
    'com.UCMobile.intl': AppCategory.utilities,
    'com.brave.browser': AppCategory.utilities,
    'com.android.filemanager': AppCategory.utilities,
    'com.google.android.apps.photos': AppCategory.utilities,
    'com.google.android.apps.maps': AppCategory.utilities,
    'com.google.android.gm': AppCategory.utilities,
    'com.google.android.apps.translate': AppCategory.utilities,
    'com.google.android.apps.walletnfcrel': AppCategory.utilities,
    'com.google.android.dialer': AppCategory.utilities,
    'com.android.gallery3d': AppCategory.utilities,
    'com.sec.android.gallery3d': AppCategory.utilities,
    'com.google.android.apps.files': AppCategory.utilities,
  };

  /// Classifies an app into an [AppCategory] using a two-step approach:
  ///
  /// 1. **Exact package name match** – O(1) lookup in the known apps map.
  /// 2. **Keyword heuristics** – falls back to keyword analysis of [appName]
  ///    if the package name is not found in the map.
  ///
  /// Returns [AppCategory.others] if no classification can be determined.
  ///
  /// - [packageName]: The Android package name (e.g., `'com.google.android.youtube'`).
  /// - [appName]: The human-readable app name (e.g., `'YouTube'`).
  static AppCategory classifyApp(String packageName, String appName) {
    // Step 1: Exact package name lookup.
    final AppCategory? knownCategory = _knownApps[packageName];
    if (knownCategory != null) {
      return knownCategory;
    }

    // Step 2: Keyword heuristics on the lowercased app name.
    final String lowerName = appName.toLowerCase();

    // Education keywords
    if (_containsAny(lowerName, [
      'learn',
      'study',
      'education',
      'school',
      'tutor',
      'quiz',
      'exam',
      'course',
      'class',
      'academy',
    ])) {
      return AppCategory.education;
    }

    // Games keywords
    if (_containsAny(lowerName, [
      'game',
      'play',
      'craft',
      'battle',
      'quest',
      'puzzle',
      'arcade',
      'racing',
    ])) {
      return AppCategory.games;
    }

    // Entertainment keywords
    if (_containsAny(lowerName, [
      'video',
      'movie',
      'music',
      'stream',
      'tv',
      'watch',
      'podcast',
      'radio',
    ])) {
      return AppCategory.entertainment;
    }

    // Social Media keywords
    if (_containsAny(lowerName, [
      'social',
      'chat',
      'feed',
      'post',
      'story',
      'reels',
      'share',
    ])) {
      return AppCategory.socialMedia;
    }

    // Communication keywords
    if (_containsAny(lowerName, [
      'message',
      'call',
      'mail',
      'email',
      'sms',
      'meeting',
      'conference',
    ])) {
      return AppCategory.communication;
    }

    // Productivity keywords
    if (_containsAny(lowerName, [
      'note',
      'doc',
      'office',
      'sheet',
      'slide',
      'task',
      'calendar',
      'project',
    ])) {
      return AppCategory.productivity;
    }

    // Shopping keywords
    if (_containsAny(lowerName, [
      'shop',
      'buy',
      'store',
      'deal',
      'cart',
      'market',
      'mall',
    ])) {
      return AppCategory.shopping;
    }

    // Finance keywords
    if (_containsAny(lowerName, [
      'bank',
      'pay',
      'money',
      'finance',
      'invest',
      'wallet',
      'upi',
      'loan',
    ])) {
      return AppCategory.finance;
    }

    // AI keywords
    if (_containsAny(lowerName, [
      'ai',
      'gpt',
      'assistant',
      'copilot',
    ])) {
      return AppCategory.ai;
    }

    // Default fallback.
    return AppCategory.others;
  }

  /// Returns `true` if [text] contains any of the [keywords].
  static bool _containsAny(String text, List<String> keywords) {
    for (final String keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
