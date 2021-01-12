import 'package:ahmed_app/services/ad_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:ahmed_app/constants.dart';
import 'package:ahmed_app/pages/bug_page.dart';
import 'package:ahmed_app/pages/privacy_policy_page.dart';
import 'package:ahmed_app/pages/suggestion_page.dart';
import 'package:ahmed_app/pages/terms_of_service_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  bool _isRewardedAdReady;

  void _loadRewardedAd() async {
    await RewardedVideoAd.instance.load(
      targetingInfo: MobileAdTargetingInfo(),
      adUnitId: AdManager.rewardedAdUnitId,
      //adUnitId: RewardedVideoAd.testAdUnitId,
    );
  }

  void _onRewardedAdEvent(RewardedVideoAdEvent event,
      {String rewardType, int rewardAmount}) {
    switch (event) {
      case RewardedVideoAdEvent.loaded:
        setState(() {
          _isRewardedAdReady = true;
        });
        break;
      case RewardedVideoAdEvent.closed:
        setState(() {
          _isRewardedAdReady = false;
        });
        _loadRewardedAd();
        break;
      case RewardedVideoAdEvent.failedToLoad:
        setState(() {
          _isRewardedAdReady = false;
        });
        print('Failed to load a rewarded ad');
        break;
      case RewardedVideoAdEvent.rewarded:
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Thank you!'),
            content:
                Text('By watching this ad, you help us make the app better!'),
          ),
        );
        break;
      default:
      // do nothing
    }
  }

  int groupValue;
  SharedPreferences sharedPreferences;

  void setupTheme() async {
    sharedPreferences = await SharedPreferences.getInstance();
    groupValue = sharedPreferences.getInt('THEME') ?? 1;
    print('THEME = $groupValue');
  }

  @override
  void initState() {
    setupTheme();
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      //adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
    );
    _loadBannerAd();

    _isRewardedAdReady = false;
    RewardedVideoAd.instance.listener = _onRewardedAdEvent;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    RewardedVideoAd.instance.listener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: AppBar(
                title: Text('Settings'),
                shape: appBarShape,
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Divider(),
                  ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Change App Theme'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile(
                                  activeColor: DynamicTheme.of(context)
                                      .data
                                      .primaryColor,
                                  title: Text('System Default'),
                                  value: 0,
                                  groupValue: groupValue,
                                  onChanged: (val) {
                                    DynamicTheme.of(context).setThemeData(
                                        SchedulerBinding.instance.window
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? appThemeLight
                                            : appThemeDark);
                                    DynamicTheme.of(context).setBrightness(
                                        SchedulerBinding.instance.window
                                            .platformBrightness);
                                    Navigator.pop(context);
                                    setState(() {
                                      groupValue = val;
                                    });
                                    sharedPreferences.setInt(
                                        'THEME', groupValue);
                                  }),
                              RadioListTile(
                                  activeColor: DynamicTheme.of(context)
                                      .data
                                      .primaryColor,
                                  title: Text('Light'),
                                  value: 1,
                                  groupValue: groupValue,
                                  onChanged: (val) {
                                    DynamicTheme.of(context)
                                        .setThemeData(appThemeLight);
                                    DynamicTheme.of(context)
                                        .setBrightness(Brightness.light);
                                    Navigator.pop(context);
                                    setState(() {
                                      groupValue = val;
                                    });
                                    sharedPreferences.setInt(
                                        'THEME', groupValue);
                                  }),
                              RadioListTile(
                                activeColor:
                                    DynamicTheme.of(context).data.primaryColor,
                                title: Text('Dark'),
                                value: 2,
                                groupValue: groupValue,
                                onChanged: (val) {
                                  DynamicTheme.of(context)
                                      .setThemeData(appThemeDark);
                                  DynamicTheme.of(context)
                                      .setBrightness(Brightness.dark);
                                  Navigator.pop(context);
                                  setState(() {
                                    groupValue = val;
                                  });
                                  sharedPreferences.setInt('THEME', groupValue);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    leading: Icon(Icons.brightness_2_outlined),
                    title: Text('Dark mode'),
                  ),
                  Divider(),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          color: DynamicTheme.of(context).data.primaryColor,
                        ),
                      )),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.bug_report),
                    title: Text('I Spotted a Bug'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => BugPage()));
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.face),
                    title: Text('I Have a Suggestion'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SuggestionPage()));
                    },
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      'More Information',
                      style: TextStyle(
                        fontSize: 16,
                        color: DynamicTheme.of(context).data.primaryColor,
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PrivacyPolicyPage()));
                    },
                    leading: Icon(Icons.privacy_tip),
                    title: Text('Privacy Policy'),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TermsOfServicePage()));
                    },
                    leading: Icon(Icons.list),
                    title: Text('Terms of Service'),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      _loadRewardedAd();
                      RewardedVideoAd.instance.show();
                    },
                    leading: Icon(Icons.star),
                    title: Text('Support us!'),
                    subtitle: Text('Help us by watching an ad video'),
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
