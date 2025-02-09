import QtQuick 2.15
import QtGraphicalEffects 1.0
import "../global"
import "../Lists"
import "../layer_help"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {

    property int numcolumns: api.memory.has("numColumns") ? api.memory.get("numColumns") : 5
    property int numcolumnsMin: 4
    property int numcolumnsMax: 6
    
    property int idx: 0
    // "By Time Last Played" "By Title" "By Total Play Time"
    property var sortTitle: {
        switch (sortByIndex) {
            case 0:
                return "By Time Last Played";
            case 1:
                return "By Total Play Time";
            case 2:
                return "By Title";
            case 3:
                return "By Publisher";
            default:
                return ""
        }
    }

    Item {
        id: softwareScreenContainer
        anchors.fill: parent
        anchors {
            left: parent.left; leftMargin: screenmargin
            right: parent.right; rightMargin: screenmargin
        }

        Keys.onPressed: {
            if (event.isAutoRepeat)
                return;
            // Y: Favorite
            if (api.keys.isDetails(event)) {
                event.accepted = true;
                if (currentGame.favorite){
                    turnOffSfx.play();
                }
                else {
                    turnOnSfx.play();
                }
                currentGame.favorite = !currentGame.favorite
                return;
            }
            // B: Go back
            if (api.keys.isCancel(event)) {
                event.accepted = true;
                if (settings.homeView == "Recent"){
                    showRecentScreen();
                } else {
                    showSystemsScreen();
                }
                return;
            }
            // Y: Zoom
            if (api.keys.isFilters(event)) {
                event.accepted = true;
                if (numcolumns < numcolumnsMax){
                    numcolumns += 1
                } else {
                    numcolumns = numcolumnsMin
                }
                api.memory.set("numColumns", numcolumns)
                return;
            }
            
            // R2: Sort
            if (api.keys.isPageDown(event)) {
                event.accepted = true;
                na.running = true
                cycleSort();
                return;
            }
            
            // R1: Cycle collection forward
            if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
                event.accepted = true;
                turnOnSfx.play();
                if (currentCollection < api.collections.count-1) {
                    nextCollection++;
                } else {
                    nextCollection = -1;
                }
            }

            // L1: Cycle collection back
            if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
                event.accepted = true;
                turnOffSfx.play();
                if (currentCollection == -1) {
                    nextCollection = api.collections.count-1;
                } else{ 
                    nextCollection--;
                }
            }
            }

        SequentialAnimation {
            id: na
            ColorAnimation { target: sortButton; property: "color"; from: sortButton.color; to: theme.press; duration: 100; easing.type: Easing.OutQuad }
            ColorAnimation { target: sortButton; property: "color"; from: theme.press; to: sortButton.color; duration: 200; easing.type: Easing.InQuad }
            }

        // Top bar
        Item {
            id: topBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            height: Math.round(screenheight * 0.1222)
            z: 5

            Image {
                id: headerIcon
                width: Math.round(screenheight*0.0611)
                height: width
                source: "../assets/images/allsoft_icon.svg"
                sourceSize.width: vpx(128)
                sourceSize.height: vpx(128)

                anchors {
                    top: parent.top; topMargin: Math.round(screenheight*0.0416)
                    left: parent.left; leftMargin: vpx(38)
                }

                Text {
                    id: collectionTitle
                    text: currentCollection == -1 ? "All Software" : api.collections.get(currentCollection).name
                    color: theme.text
                    font.family: titleFont.name
                    font.pixelSize: Math.round(screenheight*0.0277)
                    font.bold: true
                    anchors {
                        verticalCenter: headerIcon.verticalCenter
                        left: parent.right; leftMargin: vpx(12)
                    }
                }
            }


            // Nintendo's Sort Options: "By Time Last Played", "By Total Play Time", "By Title", "By Publisher"
            Rectangle {
                id: sortButton

                width: sortTypeTxt.contentWidth + vpx(90)
                height: Math.round(screenheight*0.0611)
                color: theme.main

                anchors {
                    top: parent.top; topMargin: Math.round(screenheight*0.0416)
                    right: parent.right; rightMargin: vpx(23)
                }

                Image {
                    id: sortIcon
                    width: Math.round(screenheight*0.04)
                    height: width
                    source: "../assets/images/navigation/btn_RT.png"
                    sourceSize.width: 64
                    sourceSize.height: 64
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left; leftMargin: vpx(10)
                    }
                }

                ColorOverlay {
                    anchors.fill: sortIcon
                    source: sortIcon
                    color: theme.text
                    cached: true
                }

                Text {
                    id: sortTypeTxt
                    text:sortTitle

                    anchors {
                        left: sortIcon.right
                        leftMargin: vpx(5); rightMargin: vpx(17)
                        verticalCenter: sortIcon.verticalCenter
                    }

                    color: theme.text
                    font.family: titleFont.name
                    font.weight: Font.Thin
                    font.pixelSize: Math.round(screenheight*0.02)
                    horizontalAlignment: Text.Right
                }

                Image {
                    id: sortArrow
                    width: Math.round(screenheight*0.03)
                    height: width
                    source: "../assets/images/navigation/sort_arrow.png"
                    sourceSize.width: 64
                    sourceSize.height: 64
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: sortTypeTxt.right; leftMargin: vpx(10)
                    }
                }

                ColorOverlay {
                    anchors.fill: sortArrow
                    source: sortArrow
                    color: theme.text
                    cached: true
                }
            }

            MouseArea {
                anchors.fill: sortButton
                hoverEnabled: true
                onEntered: {}
                onExited: {}
                onClicked: {na.running = true; cycleSort();}
            }


            ColorOverlay {
                anchors.fill: headerIcon
                source: headerIcon
                color: theme.text
                cached: true
            }

            MouseArea {
                anchors.fill: headerIcon
                hoverEnabled: true
                onEntered: {}
                onExited: {}
                onClicked: {}
            }

            // Line
            Rectangle {
                y: parent.height - vpx(1)
                anchors.left: parent.left; anchors.right: parent.right
                height: 1
                color: theme.secondary
            }

        }

        // Grid masks (better performance than using clip: true)
        Rectangle {
            anchors {
                left: parent.left; top: parent.top; right: parent.right
            }
            color: theme.main
            height: topBar.height
            z: 4
        }
        
        // Game grid
        GridView {
            id: gameGrid
            focus: true

            NumberAnimation { id: anim; property: "scale"; to: 0.7; duration: 100 }

            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    anim.start();
                    playSoftware();
                }
            }

            Keys.onUpPressed:       { navSound.play(); moveCurrentIndexUp() }
            Keys.onDownPressed:     { navSound.play(); moveCurrentIndexDown() }
            Keys.onLeftPressed:     { navSound.play(); moveCurrentIndexLeft() }
            Keys.onRightPressed:    { navSound.play(); moveCurrentIndexRight() }

            onCurrentIndexChanged: {
                currentGameIndex = currentIndex;
                return;
            }

            anchors {
                left: parent.left; leftMargin: vpx(48)
                top: topBar.bottom; topMargin: -vpx(20)
                right: parent.right; rightMargin: vpx(48)
                bottom: parent.bottom
            }
			topMargin: Math.round(screenheight*0.12)
            bottomMargin: Math.round(screenheight*0.12)
            
            cellWidth: width / numcolumns
            cellHeight: cellWidth
            preferredHighlightBegin: Math.round(screenheight*0.1388)
            preferredHighlightEnd: Math.round(screenheight*0.6527)
            highlightRangeMode: ListView.ApplyRange//StrictlyEnforceRange // Highlight never moves outside the range
            snapMode: ListView.NoSnap
            highlightMoveDuration: 100//200 //150 is default

            
            model: softwareList[sortByIndex].games //api.collections.get(collectionIndex).games
            delegate: gameGridDelegate

            Component {
                id: gameGridDelegate
                
                Item {
                    id: delegateContainer
                    property bool selected: delegateContainer.GridView.isCurrentItem
                    onSelectedChanged: { if (selected) updateData() }

                    function updateData() {
                        currentGame = modelData;
                    }

                    width: gameGrid.cellWidth - vpx(10)
                    height: width
                    z: selected ? 10 : 0

                    // Preference order for Game Backgrounds
                    property var gameBG: {
                        return getGameBackground(modelData, settings.gameBackground);
                    }

                    Image {
                        id: gameImage
                        width: parent.width
                        height: parent.height
                        asynchronous: true
                        smooth: true
                        source: modelData.collections.get(0).shortName === "steam" ? modelData.assets.screenshot : gameBG
                        sourceSize { width: 256; height: 256 }
                        fillMode: (gameBG == modelData.assets.boxFront) ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                        layer.enabled: enableDropShadows //FIXME: disabled because it blurs the gameImages.
                        layer.effect: DropShadow {
                            transparentBorder: true
                            horizontalOffset: 0
                            verticalOffset: 0
                            color: "#4D000000"
                            radius: 3.0
                            samples: 6
                            z: -200
                        }
                        
                        Rectangle {
                            id: favicon
                            anchors { 
                                right: parent.right; rightMargin: vpx(5); 
                                top: parent.top; topMargin: vpx(5) 
                            }
                            width: vpx(28)
                            height: width
                            radius: width/2
                            color: theme.accent
                            visible: modelData.favorite
                            Image {
                                id: faviconImage
                                source: "../assets/images/heart_filled.png"
                                asynchronous: true
                                anchors.fill: parent
                                anchors.margins: vpx(7)            
                            }
                            
                            ColorOverlay {
                                anchors.fill: faviconImage
                                source: faviconImage
                                color: theme.icon
                                antialiasing: true
                                smooth: true
                                cached: true
                            }
                        }
                    }

                    //white overlay on screenshot for better logo visibility over screenshot
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: theme.main
                        opacity: 0.15
                        visible: logo.source != "" && gameImage.source != ""
                    }

                    // Logo
                    Image {
                        id: logo

                        width: gameImage.width
                        height: gameImage.height
                        anchors {
                            fill: parent
                            margins: vpx(6)
                        }

                        asynchronous: true

                        property var logoImage: {
                            if (modelData != null) {
                                if (modelData.collections.get(0).shortName === "retropie")
                                    return "";//modelData.assets.boxFront;
                                else if (modelData.collections.get(0).shortName === "steam")
                                    return Utils.logo(modelData) ? Utils.logo(modelData) : "" //root.logo(modelData);
                                else if (modelData.assets.tile != "")
                                    return "";
                                else
                                    return modelData.assets.logo;
                            } else {
                                return ""
                            }
                        }

                        //opacity: 0
                        source: modelData ? logoImage || "" : "" //modelData.assets.logo ? modelData.assets.logo : ""
                        sourceSize { width: 256; height: 256 }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: modelData.assets.logo && gameBG != modelData.assets.boxFront ? true : false
                        z:8
                    }

                    MouseArea {
                        anchors.fill: gameImage
                        hoverEnabled: true
                        onEntered: {}
                        onExited: {}
                        onClicked: {
                            if (selected) {
                                anim.start();
                                playSoftware();
                            }
                            else
                                navSound.play();
                                gameGrid.currentIndex = index
                        }
                    }

                    //NumberAnimation { id: anim; property: "scale"; to: 0.7; duration: 100 }
                    //NumberAnimation { property: "scale"; to: 1.0; duration: 100 }
                    
                    Rectangle {
                        id: outerborder
                        width: gameImage.width
                        height: gameImage.height
                        color: theme.button//"white"
                        z: -1

                        Rectangle {
                            anchors.fill: outerborder
                            anchors.margins: vpx(4)
                            color: theme.button
                            z: 7
                        }

                        Text {
                            text: modelData.title
                            x: vpx(8)
                            width: parent.width - vpx(16)
                            height: parent.height
                            font.family: titleFont.name
                            color: theme.text
                            font.pixelSize: Math.round(screenheight*0.0194)
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.Wrap
                            visible: logo.source == "" && gameImage.source == ""//!modelData.assets.logo
                            z: 10
                        }
                    }
                        

                    // Title bubble
                    Rectangle {
                        id: titleBubble
                        width: gameTitle.contentWidth + vpx(54)
                        height: Math.round(screenheight*0.0611)
                        color: theme.button
                        radius: vpx(4)
                        
                        // Need to figure out how to stop it from clipping the margin
                        // mapFromItem and mapToItem are probably going to help
                        property int xpos: gameImage.width/2 - width/2
                        x: xpos
                        //y: highlightBorder.y//vpx(-63)
                        z: 10 * index

                        anchors {
                            horizontalCenter: bubbletriangle.horizontalCenter
                            bottom: bubbletriangle.top
                        }
                        
                        opacity: selected ? 0.95 : 0
                        //Behavior on opacity { NumberAnimation { duration: 50 } }

                        Text {
                            id: gameTitle
                            text: sortByIndex == 3 ? modelData.publisher + " / " + modelData.title : modelData.title
                            color: theme.accent
                            font.pixelSize: Math.round(screenheight*0.0222)
                            font.bold: true
                            font.family: titleFont.name
                            //horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left; leftMargin: vpx(27)
                            }
                            
                        }

                        Component.onCompleted: {
                            if (wordWrap) {
                                if (gameTitle.paintedWidth > gameImage.width * 1.75) {
                                    gameTitle.width = gameImage.width * 1.5 - vpx(54)
                                    titleBubble.height = titleBubble.height * 1.5
                                }
                            }
                            
                        }
                    }

                    Image {
                        id: bubbletriangle
                        source: "../assets/images/triangle.svg"
                        width: vpx(17)
                        height: Math.round(screenheight*0.0152)
                        opacity: 0
                        x: gameImage.width/2 - width/2
                        anchors.bottom: gameImage.top
                    }

                    ColorOverlay {
                        anchors.fill: bubbletriangle
                        source: bubbletriangle
                        color: theme.button
                        cached: true
                        opacity: titleBubble.opacity
                    }

                    // Border
                    HighlightBorder {
                        id: highlightBorder
                        width: gameImage.width + vpx(18)
                        height: width

                        
                        anchors.centerIn: gameImage
                        
                        //x: vpx(-7)
                        //y: vpx(-7)
                        z: -10

                        selected: delegateContainer.GridView.isCurrentItem
                    }

                }
            }
        }

    }
}
