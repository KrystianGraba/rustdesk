import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/utils/multi_window_manager.dart';
import 'package:get/get.dart';

import '../../common.dart';
import '../../models/model.dart';
import '../../models/peer_model.dart';
import '../../models/platform_model.dart';

typedef PopupMenuItemsFunc = Future<List<PopupMenuItem<String>>> Function();

enum PeerType { recent, fav, discovered, ab }

enum PeerUiType { grid, list }

final peerCardUiType = PeerUiType.grid.obs;

class _PeerCard extends StatefulWidget {
  final Peer peer;
  final PopupMenuItemsFunc popupMenuItemsFunc;
  final PeerType type;

  _PeerCard(
      {required this.peer,
      required this.popupMenuItemsFunc,
      Key? key,
      required this.type})
      : super(key: key);

  @override
  _PeerCardState createState() => _PeerCardState();
}

/// State for the connection page.
class _PeerCardState extends State<_PeerCard>
    with AutomaticKeepAliveClientMixin {
  var _menuPos = RelativeRect.fill;
  final double _cardRadis = 20;
  final double _borderWidth = 2;
  final RxBool _iconMoreHover = false.obs;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final peer = super.widget.peer;
    var deco = Rx<BoxDecoration?>(BoxDecoration(
        border: Border.all(color: Colors.transparent, width: _borderWidth),
        borderRadius: peerCardUiType.value == PeerUiType.grid
            ? BorderRadius.circular(_cardRadis)
            : null));
    return MouseRegion(
      onEnter: (evt) {
        deco.value = BoxDecoration(
            border: Border.all(color: MyTheme.button, width: _borderWidth),
            borderRadius: peerCardUiType.value == PeerUiType.grid
                ? BorderRadius.circular(_cardRadis)
                : null);
      },
      onExit: (evt) {
        deco.value = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: _borderWidth),
            borderRadius: peerCardUiType.value == PeerUiType.grid
                ? BorderRadius.circular(_cardRadis)
                : null);
      },
      child: GestureDetector(
          onDoubleTap: () => _connect(peer.id),
          child: Obx(() => peerCardUiType.value == PeerUiType.grid
              ? _buildPeerCard(context, peer, deco)
              : _buildPeerTile(context, peer, deco))),
    );
  }

  Widget _buildPeerTile(
      BuildContext context, Peer peer, Rx<BoxDecoration?> deco) {
    final greyStyle =
        TextStyle(fontSize: 12, color: MyTheme.color(context).lighterText);
    return Obx(
      () => Container(
        foregroundDecoration: deco.value,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                color: str2color('${peer.id}${peer.platform}', 0x7f),
              ),
              alignment: Alignment.center,
              child: _getPlatformImage('${peer.platform}', 30).paddingAll(6),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: MyTheme.color(context).bg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 4, 4, 4),
                                child: CircleAvatar(
                                    radius: 5,
                                    backgroundColor: peer.online
                                        ? Colors.green
                                        : Colors.yellow)),
                            Text(
                              '${peer.id}',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ]),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FutureBuilder<String>(
                              future: bind.mainGetPeerOption(
                                  id: peer.id, key: 'alias'),
                              builder: (_, snapshot) {
                                if (snapshot.hasData) {
                                  final name = snapshot.data!.isEmpty
                                      ? '${peer.username}@${peer.hostname}'
                                      : snapshot.data!;
                                  return Tooltip(
                                    message: name,
                                    waitDuration: Duration(seconds: 1),
                                    child: Text(
                                      name,
                                      style: greyStyle,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                } else {
                                  // alias has not arrived
                                  return Text(
                                    '${peer.username}@${peer.hostname}',
                                    style: greyStyle,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _actionMore(peer),
                  ],
                ).paddingSymmetric(horizontal: 4.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPeerCard(
      BuildContext context, Peer peer, Rx<BoxDecoration?> deco) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Obx(
        () => Container(
          foregroundDecoration: deco.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_cardRadis - _borderWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: str2color('${peer.id}${peer.platform}', 0x7f),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                child:
                                    _getPlatformImage('${peer.platform}', 60),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: FutureBuilder<String>(
                                      future: bind.mainGetPeerOption(
                                          id: peer.id, key: 'alias'),
                                      builder: (_, snapshot) {
                                        if (snapshot.hasData) {
                                          final name = snapshot.data!.isEmpty
                                              ? '${peer.username}@${peer.hostname}'
                                              : snapshot.data!;
                                          return Tooltip(
                                            message: name,
                                            waitDuration: Duration(seconds: 1),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        } else {
                                          // alias has not arrived
                                          return Center(
                                              child: Text(
                                            '${peer.username}@${peer.hostname}',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).paddingAll(4.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: MyTheme.color(context).bg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 4, 8, 4),
                            child: CircleAvatar(
                                radius: 5,
                                backgroundColor: peer.online
                                    ? Colors.green
                                    : Colors.yellow)),
                        Text('${peer.id}')
                      ]).paddingSymmetric(vertical: 8),
                      _actionMore(peer),
                    ],
                  ).paddingSymmetric(horizontal: 12.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionMore(Peer peer) => Listener(
      onPointerDown: (e) {
        final x = e.position.dx;
        final y = e.position.dy;
        _menuPos = RelativeRect.fromLTRB(x, y, x, y);
      },
      onPointerUp: (_) => _showPeerMenu(context, peer.id),
      child: MouseRegion(
          onEnter: (_) => _iconMoreHover.value = true,
          onExit: (_) => _iconMoreHover.value = false,
          child: CircleAvatar(
              radius: 14,
              backgroundColor: _iconMoreHover.value
                  ? MyTheme.color(context).grayBg!
                  : MyTheme.color(context).bg!,
              child: Icon(Icons.more_vert,
                  size: 18,
                  color: _iconMoreHover.value
                      ? MyTheme.color(context).text
                      : MyTheme.color(context).lightText))));

  /// Connect to a peer with [id].
  /// If [isFileTransfer], starts a session only for file transfer.
  void _connect(String id, {bool isFileTransfer = false}) async {
    if (id == '') return;
    id = id.replaceAll(' ', '');
    if (isFileTransfer) {
      await rustDeskWinManager.new_file_transfer(id);
    } else {
      await rustDeskWinManager.new_remote_desktop(id);
    }
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  /// Show the peer menu and handle user's choice.
  /// User might remove the peer or send a file to the peer.
  void _showPeerMenu(BuildContext context, String id) async {
    var value = await showMenu(
      context: context,
      position: _menuPos,
      items: await super.widget.popupMenuItemsFunc(),
      elevation: 8,
    );
    if (value == 'remove') {
      await bind.mainRemovePeer(id: id);
      removePreference(id);
      Get.forceAppUpdate(); // TODO use inner model / state
    } else if (value == 'file') {
      _connect(id, isFileTransfer: true);
    } else if (value == 'add-fav') {
      final favs = (await bind.mainGetFav()).toList();
      if (favs.indexOf(id) < 0) {
        favs.add(id);
        bind.mainStoreFav(favs: favs);
      }
    } else if (value == 'remove-fav') {
      final favs = (await bind.mainGetFav()).toList();
      if (favs.remove(id)) {
        bind.mainStoreFav(favs: favs);
        Get.forceAppUpdate(); // TODO use inner model / state
      }
    } else if (value == 'connect') {
      _connect(id, isFileTransfer: false);
    } else if (value == 'ab-delete') {
      gFFI.abModel.deletePeer(id);
      await gFFI.abModel.updateAb();
      setState(() {});
    } else if (value == 'ab-edit-tag') {
      _abEditTag(id);
    } else if (value == 'rename') {
      _rename(id);
    } else if (value == 'unremember-password') {
      await bind.mainForgetPassword(id: id);
    } else if (value == 'force-always-relay') {
      String value;
      String oldValue =
          await bind.mainGetPeerOption(id: id, key: 'force-always-relay');
      if (oldValue.isEmpty) {
        value = 'Y';
      } else {
        value = '';
      }
      await bind.mainSetPeerOption(
          id: id, key: 'force-always-relay', value: value);
    }
  }

  Widget _buildTag(String tagName, RxList<dynamic> rxTags,
      {Function()? onTap}) {
    return ContextMenuArea(
      width: 100,
      builder: (context) => [
        ListTile(
          title: Text(translate("Delete")),
          onTap: () {
            gFFI.abModel.deleteTag(tagName);
            gFFI.abModel.updateAb();
            Future.delayed(Duration.zero, () => Get.back());
          },
        )
      ],
      child: GestureDetector(
        onTap: onTap,
        child: Obx(
          () => Container(
            decoration: BoxDecoration(
                color: rxTags.contains(tagName) ? Colors.blue : null,
                border: Border.all(color: MyTheme.darkGray),
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: Text(
              tagName,
              style: TextStyle(
                  color: rxTags.contains(tagName) ? MyTheme.white : null),
            ),
          ),
        ),
      ),
    );
  }

  /// Get the image for the current [platform].
  Widget _getPlatformImage(String platform, double size) {
    platform = platform.toLowerCase();
    if (platform == 'mac os')
      platform = 'mac';
    else if (platform != 'linux' && platform != 'android') platform = 'win';
    return Image.asset('assets/$platform.png', height: size, width: size);
  }

  void _abEditTag(String id) {
    var isInProgress = false;

    final tags = List.of(gFFI.abModel.tags);
    var selectedTag = gFFI.abModel.getPeerTags(id).obs;

    gFFI.dialogManager.show((setState, close) {
      return CustomAlertDialog(
        title: Text(translate("Edit Tag")),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                children: tags
                    .map((e) => _buildTag(e, selectedTag, onTap: () {
                          if (selectedTag.contains(e)) {
                            selectedTag.remove(e);
                          } else {
                            selectedTag.add(e);
                          }
                        }))
                    .toList(growable: false),
              ),
            ),
            Offstage(offstage: !isInProgress, child: LinearProgressIndicator())
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                close();
              },
              child: Text(translate("Cancel"))),
          TextButton(
              onPressed: () async {
                setState(() {
                  isInProgress = true;
                });
                gFFI.abModel.changeTagForPeer(id, selectedTag);
                await gFFI.abModel.updateAb();
                close();
              },
              child: Text(translate("OK"))),
        ],
      );
    });
  }

  void _rename(String id) async {
    var isInProgress = false;
    var name = await bind.mainGetPeerOption(id: id, key: 'alias');
    if (widget.type == PeerType.ab) {
      final peer = gFFI.abModel.peers.firstWhere((p) => id == p['id']);
      if (peer == null) {
        // this should not happen
      } else {
        name = peer['alias'] ?? "";
      }
    }
    final k = GlobalKey<FormState>();
    gFFI.dialogManager.show((setState, close) {
      return CustomAlertDialog(
        title: Text(translate("Rename")),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Form(
                key: k,
                child: TextFormField(
                  controller: TextEditingController(text: name),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (newStr) {
                    name = newStr;
                  },
                  validator: (s) {
                    if (s == null || s.isEmpty) {
                      return translate("Empty");
                    }
                    return null;
                  },
                  onSaved: (s) {
                    name = s ?? "unnamed";
                  },
                ),
              ),
            ),
            Offstage(offstage: !isInProgress, child: LinearProgressIndicator())
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                close();
              },
              child: Text(translate("Cancel"))),
          TextButton(
              onPressed: () async {
                setState(() {
                  isInProgress = true;
                });
                if (k.currentState != null) {
                  if (k.currentState!.validate()) {
                    k.currentState!.save();
                    await bind.mainSetPeerOption(
                        id: id, key: 'alias', value: name);
                    if (widget.type == PeerType.ab) {
                      gFFI.abModel.setPeerOption(id, 'alias', name);
                      await gFFI.abModel.updateAb();
                    } else {
                      Future.delayed(Duration.zero, () {
                        this.setState(() {});
                      });
                    }
                    close();
                  }
                }
                setState(() {
                  isInProgress = false;
                });
              },
              child: Text(translate("OK"))),
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

abstract class BasePeerCard extends StatelessWidget {
  final Peer peer;
  final PeerType type;

  BasePeerCard({required this.peer, required this.type, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PeerCard(
      peer: peer,
      popupMenuItemsFunc: _getPopupMenuItems,
      type: type,
    );
  }

  @protected
  Future<List<PopupMenuItem<String>>> _getPopupMenuItems();
}

class RecentPeerCard extends BasePeerCard {
  RecentPeerCard({required Peer peer, Key? key})
      : super(peer: peer, key: key, type: PeerType.recent);

  Future<List<PopupMenuItem<String>>> _getPopupMenuItems() async {
    return [
      PopupMenuItem<String>(
          child: Text(translate('Connect')), value: 'connect'),
      PopupMenuItem<String>(
          child: Text(translate('Transfer File')), value: 'file'),
      PopupMenuItem<String>(
          child: Text(translate('TCP Tunneling')), value: 'tcp-tunnel'),
      await _forceAlwaysRelayMenuItem(peer.id),
      PopupMenuItem<String>(child: Text(translate('Rename')), value: 'rename'),
      PopupMenuItem<String>(child: Text(translate('Remove')), value: 'remove'),
      PopupMenuItem<String>(
          child: Text(translate('Unremember Password')),
          value: 'unremember-password'),
      PopupMenuItem<String>(
          child: Text(translate('Add to Favorites')), value: 'add-fav'),
    ];
  }
}

class FavoritePeerCard extends BasePeerCard {
  FavoritePeerCard({required Peer peer, Key? key})
      : super(peer: peer, key: key, type: PeerType.fav);

  Future<List<PopupMenuItem<String>>> _getPopupMenuItems() async {
    return [
      PopupMenuItem<String>(
          child: Text(translate('Connect')), value: 'connect'),
      PopupMenuItem<String>(
          child: Text(translate('Transfer File')), value: 'file'),
      PopupMenuItem<String>(
          child: Text(translate('TCP Tunneling')), value: 'tcp-tunnel'),
      await _forceAlwaysRelayMenuItem(peer.id),
      PopupMenuItem<String>(child: Text(translate('Rename')), value: 'rename'),
      PopupMenuItem<String>(child: Text(translate('Remove')), value: 'remove'),
      PopupMenuItem<String>(
          child: Text(translate('Unremember Password')),
          value: 'unremember-password'),
      PopupMenuItem<String>(
          child: Text(translate('Remove from Favorites')), value: 'remove-fav'),
    ];
  }
}

class DiscoveredPeerCard extends BasePeerCard {
  DiscoveredPeerCard({required Peer peer, Key? key})
      : super(peer: peer, key: key, type: PeerType.discovered);

  Future<List<PopupMenuItem<String>>> _getPopupMenuItems() async {
    return [
      PopupMenuItem<String>(
          child: Text(translate('Connect')), value: 'connect'),
      PopupMenuItem<String>(
          child: Text(translate('Transfer File')), value: 'file'),
      PopupMenuItem<String>(
          child: Text(translate('TCP Tunneling')), value: 'tcp-tunnel'),
      await _forceAlwaysRelayMenuItem(peer.id),
      PopupMenuItem<String>(child: Text(translate('Rename')), value: 'rename'),
      PopupMenuItem<String>(child: Text(translate('Remove')), value: 'remove'),
      PopupMenuItem<String>(
          child: Text(translate('Unremember Password')),
          value: 'unremember-password'),
      PopupMenuItem<String>(
          child: Text(translate('Add to Favorites')), value: 'add-fav'),
    ];
  }
}

class AddressBookPeerCard extends BasePeerCard {
  AddressBookPeerCard({required Peer peer, Key? key})
      : super(peer: peer, key: key, type: PeerType.ab);

  Future<List<PopupMenuItem<String>>> _getPopupMenuItems() async {
    return [
      PopupMenuItem<String>(
          child: Text(translate('Connect')), value: 'connect'),
      PopupMenuItem<String>(
          child: Text(translate('Transfer File')), value: 'file'),
      PopupMenuItem<String>(
          child: Text(translate('TCP Tunneling')), value: 'tcp-tunnel'),
      await _forceAlwaysRelayMenuItem(peer.id),
      PopupMenuItem<String>(child: Text(translate('Rename')), value: 'rename'),
      PopupMenuItem<String>(
          child: Text(translate('Remove')), value: 'ab-delete'),
      PopupMenuItem<String>(
          child: Text(translate('Unremember Password')),
          value: 'unremember-password'),
      PopupMenuItem<String>(
          child: Text(translate('Add to Favorites')), value: 'add-fav'),
      PopupMenuItem<String>(
          child: Text(translate('Edit Tag')), value: 'ab-edit-tag'),
    ];
  }
}

Future<PopupMenuItem<String>> _forceAlwaysRelayMenuItem(String id) async {
  bool force_always_relay =
      (await bind.mainGetPeerOption(id: id, key: 'force-always-relay'))
          .isNotEmpty;
  return PopupMenuItem<String>(
      child: Row(
        children: [
          Offstage(
            offstage: !force_always_relay,
            child: Icon(Icons.check),
          ),
          Text(translate('Always connect via relay')),
        ],
      ),
      value: 'force-always-relay');
}
