import QtQuick 2.13
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import QtCharts 2.0
import QtGraphicalEffects 1.13

Item {
    id: page
    height: 475
    property alias imageToolLogo: imageToolLogo
    property alias rectangleSplashScreen: rectangleSplashScreen
    property alias rectangleCostItemNames: rectangleCostItemNames
    property alias listViewCostItemNames: listViewCostItemNames
    property alias chartMonthExpNec: chartMonthExpNec

    property alias buttonPreviousMonth: buttonPreviousMonth
    property alias buttonNextMonth: buttonNextMonth
    property alias page: page
    property alias labelCalendar: labelCalendar
    property alias listViewExpenditure: listViewExpenditure
    property alias buttonAddCostItem: buttonAddCostItem
    property alias toolButtonClose: toolButtonClose
    property alias toolButtonBack: toolButtonBack
    property alias toolButtonApply: toolButtonApply
    property alias labelCostItemDate: labelCostItemDate
    property alias comboBoxCostItemDate: comboBoxCostItemDate
    property alias textFieldCostItemName: textFieldCostItemName
    property alias labelCostItemNameWarning: labelCostItemNameWarning
    property alias listViewCostTerms: listViewCostTerms
    property alias labelCost: labelCost
    property alias buttonAddCostTerm: buttonAddCostTerm
    property alias textFieldCostTerm: textFieldCostTerm
    property alias pageCostItem: pageCostItem
    property alias switchNecessaryExpenditure: switchNecessaryExpenditure
    property alias labelOverspend: labelOverspend
    property alias labelTotalCost: labelTotalCost
    property alias textFieldBudget: textFieldBudget
    property alias labelBudgetWarning: labelBudgetWarning
    property alias buttonCancelCostItemSel: buttonCancelCostItemSel
    property alias labelOverspendName: labelOverspendName
    property alias pieSeriesMonthExpByType: pieSeriesMonthExpByType
    property alias pieSeriesMonthExpByNec: pieSeriesMonthExpByNec
    property alias barCategoryAxisYearExp: barCategoryAxisYearExp
    property alias valueAxisYearExp: valueAxisYearExp
    property alias stackedBarSeriesYearExp: stackedBarSeriesYearExp

    //Цветовая схема (material disign)
    //Основной цвет
    readonly property string primaryColor: "#000036"
    readonly property string primaryColorDark: "#000013"
    readonly property string primaryColorLight: "#2b2b60"
    //Вторичный цвет
    readonly property string secondaryColor: "#ffa726"
    readonly property string secondaryColorDark: "#c77800"
    readonly property string secondaryColorLight: "#ffd95b"
    //Цвет для предупреждения об угрозе (например для выделения необязательной траты в списках)
    readonly property string alertColor: "#ec407a"
    //Цвет текста
    readonly property string contentTextColorDark: "#dd000000"
    //Цвет для выделения хорошего значения
    readonly property string goodConditionsColor: "#4CAF50"

    //Шрифты
    //Размер шрифта в диаграммах
    readonly property int chartFontPixelSize: 14


    Material.accent: secondaryColor

    //Картинки
    readonly property string iconAdd: "qrc:/images/baseline-add-24px.svg"
    readonly property string iconDelete: "qrc:/images/baseline-delete_forever-24px.svg"
    readonly property string iconBack: "qrc:/images/baseline-arrow_back-24px.svg"
    readonly property string iconNextArrow: "qrc:/images/baseline-next_arrow-24px.svg"
    readonly property string iconPrevArrow: "qrc:/images/baseline-prev_arrow-24px.svg"
    readonly property string iconClose: "qrc:/images/baseline-close-24px.svg"
    readonly property string iconCheck: "qrc:/images/baseline-check-24px.svg"
    readonly property string iconLogo: "qrc:/images/ic_launcher_mysicka_v5.svg"

    property alias pageExpenditure: pageExpenditure
    property alias chartMonthExpByType: chartMonthExpByType
    property alias pageIndicator: pageIndicator
    property alias swipeView: swipeView
    property alias labelMainTitle: labelMainTitle
    property alias rectangleMonth: rectangleMonth

    //pageCostItem

    //itemExpenditure

    //itemGraph


    Page {
        id: pageMain
        font.pointSize: 12
        anchors.fill: parent

        header: ToolBar {
            id: toolBarMain
            height: 48
            font.pointSize: 12
            spacing: 11

            background: Rectangle {
                color: primaryColor
                anchors.fill: parent
                visible: true
            } //background Rectangle

            Label {
                id: labelMainTitle
                color: "#ffffff"
                text: "расходы"
                anchors.verticalCenterOffset: 9
                font.bold: true
                font.pointSize: 14

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }//labelMainTitle

            Image {
                id: imageToolLogo
                height: parent.height - 4
                width: height
                anchors.left: parent.left
                anchors.leftMargin: 2
                source: iconLogo
                fillMode: Image.PreserveAspectFit
            }

            ToolButton {
                id: toolButtonClose
                anchors.right: parent.right
                anchors.rightMargin: 3

                icon.source: iconClose
                icon.color: "#ffffff"
                icon.width: width/2
                icon.height: height/2

                spacing: 2
            }

            ToolButton {
                id: toolButtonApply
                visible: false
                anchors.right: parent.right
                anchors.rightMargin: 3
                icon.source: iconCheck
                icon.color: "#ffffff"
                icon.width: width/2
                icon.height: height/2

                spacing: 2
            } //toolButtonApply

            ToolButton {
                id: toolButtonBack
                visible: false
                anchors.left: parent.left
                anchors.leftMargin: 0
                icon.source: iconBack
                icon.color: "#ffffff"
                icon.width: width/2
                icon.height: height/2

                spacing: 2
            } //toolButtonBack
        } //toolBarMain

        Column {
            id: column2
            anchors.fill: parent

            Rectangle {
                id: rectangleMonth
                height: 50
                color: "#2b2b60"
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                RowLayout {
                    id: rowLayout
                    width: 272
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 5
                    anchors.top: parent.top
                    anchors.topMargin: 0

                    RoundButton {
                        id: buttonPreviousMonth
                        width: 56
                        height: 56
                        Layout.fillWidth: false
                        Layout.minimumWidth: 0
                        checkable: false
                        spacing: -3

                        Material.background: secondaryColor
                        icon.source: iconPrevArrow
                        icon.width: width/2
                        icon.height: height/2
                    }

                    Label {
                        id: labelCalendar
                        text: qsTr("сентябрь 2017")
                        font.pointSize: 16
                        color: "#ffffff"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    RoundButton {
                        id: buttonNextMonth
                        width: 56
                        height: 56
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        font.capitalization: Font.Capitalize

                        Material.background: secondaryColor
                        icon.source: iconNextArrow
                        icon.width: width/2
                        icon.height: height/2
                    }
                }
            }

            SwipeView {
                id: swipeView
                anchors.topMargin: rectangleMonth.height
                anchors.fill: parent
                visible: true


                Item {
                    id: itemExpenditure

                    Page {
                        id: pageExpenditure
                        anchors.bottomMargin: 0
                        font.pointSize: 16
                        anchors.fill: parent
                        visible: true
                        title: ""

                        ColumnLayout {
                            id: columnLayout
                            anchors.topMargin: 10
                            anchors.fill: parent

                            GridLayout {
                                id: gridLayout
                                x: 6
                                width: 100
                                height: 120
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillWidth: false
                                rows: 3
                                columns: 2

                                Label {
                                    id: label7
                                    x: 8
                                    text: qsTr("ИТОГО расход: ")
                                    font.bold: false
                                    font.pointSize: 16
                                }

                                Label {
                                    id: labelTotalCost
                                    text: qsTr("0")
                                    font.bold: true
                                    font.pointSize: 15
                                    horizontalAlignment: Text.AlignRight
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                }

                                Label {
                                    id: label6
                                    text: qsTr("Бюджет: ")
                                    font.bold: false
                                    font.pointSize: 14
                                }

                                TextField {
                                    id: textFieldBudget
                                    text: "0"
                                    font.pixelSize: 16
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                    placeholderText: qsTr("Text Field")
                                    //Настройка, чтобы при вводе появлялась клавиатура с цифрами
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                    Label {
                                        id: labelBudgetWarning
                                        color: "#dd1037"
                                        text: qsTr("Label")
                                        visible: false
                                        anchors.top: parent.top
                                        anchors.topMargin: 36
                                    }
                                }

                                Label {
                                    id: labelOverspendName
                                    text: qsTr("Перерасход: ")
                                    font.pointSize: 15
                                }

                                Label {
                                    id: labelOverspend
                                    text: qsTr("0")
                                    font.kerning: true
                                    font.bold: true
                                    font.pointSize: 16
                                    horizontalAlignment: Text.AlignRight
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                }
                            }

                            Rectangle {
                                id: rectangle9
                                width: 200
                                height: 80
                                color: "#00000000"
                                Layout.fillWidth: true

                                RoundButton {
                                    id: buttonAddCostItem
                                    x: 572
                                    y: 39
                                    width: 64
                                    height: 64
                                    flat: false
                                    anchors.right: parent.right
                                    anchors.rightMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8
                                    focusPolicy: Qt.NoFocus
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                    Material.background: secondaryColor
                                    icon.source: iconAdd
                                    icon.width: width/2
                                    icon.height: height/2
                                }

                                RoundButton {
                                    id: buttonCancelCostItemSel
                                    y: 30
                                    width: 64
                                    height: 64
                                    visible: false
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    spacing: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                    focusPolicy: Qt.NoFocus
                                    Material.background: secondaryColor
                                    icon.source: iconBack
                                    icon.width: width/2
                                    icon.height: height/2
                                }
                            }

                            ListView {
                                id: listViewExpenditure
                                width: 110
                                height: 160
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                boundsBehavior: Flickable.StopAtBounds
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                //Необходимо включать это свойство, чтобы компонеты списка обезались его границами
                                clip: enabled
                            }
                        }

                        //scrollViewMain

                    }//pageExpenditure

                    Page {

                        id: pageCostItem
                        anchors.fill: parent
                        clip: false
                        wheelEnabled: true

                        ScrollView {
                            id: scrollViewCostItem
                            anchors.fill: parent
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                            clip: true

                            /*!необходимо задавать ширину равной видимой ширине окна содержащего контент ScrollView,
                          иначе все элементы будут смещены*/
                            contentWidth: parent.width

                            Column {
                                id: column
                                y: 0
                                anchors.right: parent.right
                                anchors.rightMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0

                                Rectangle {
                                    id: rectangle1
                                    y: 46
                                    height: 50
                                    color: "#00000000"
                                    border.color: "#00000000"
                                    border.width: 0
                                    anchors.rightMargin: 0
                                    anchors.leftMargin: 0
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    Label {
                                        id: label
                                        y: 53
                                        text: qsTr("Дата")
                                        lineHeight: 1.1
                                        anchors.left: parent.left
                                        anchors.leftMargin: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        Layout.columnSpan: 1
                                        Layout.rowSpan: 1
                                        textFormat: Text.PlainText
                                    }

                                    ComboBox {
                                        id: comboBoxCostItemDate
                                        x: 444
                                        y: 36
                                        width: 80
                                        height: 50
                                        rightPadding: 36
                                        anchors.right: parent.right
                                        anchors.rightMargin: 87
                                        anchors.verticalCenter: parent.verticalCenter
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        Layout.fillWidth: false
                                        Layout.fillHeight: true
                                        font.pixelSize: 11
                                        spacing: -2
                                        currentIndex: 2
                                    }

                                    Label {
                                        id: labelCostItemDate
                                        x: 558
                                        y: 53
                                        text: qsTr("mm.yyyy")
                                        anchors.right: parent.right
                                        anchors.rightMargin: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        Layout.fillWidth: false
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    }
                                }

                                Rectangle {
                                    id: rectangle
                                    y: 46
                                    width: 640
                                    height: 79
                                    color: "#00000000"
                                    border.width: 0
                                    border.color: primaryColor
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.left: parent.left
                                    anchors.leftMargin: 0

                                    Rectangle {
                                        id: rectangle2
                                        width: 640
                                        height: 1
                                        color: primaryColor
                                        anchors.top: parent.top
                                        anchors.topMargin: 0
                                    }

                                    Label {
                                        id: label1
                                        y: 67
                                        width: 105
                                        text: qsTr("Наименование")
                                        renderType: Text.QtRendering
                                        anchors.left: parent.left
                                        anchors.leftMargin: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        textFormat: Text.PlainText
                                        Layout.rowSpan: 1
                                        Layout.columnSpan: 1
                                    }

                                    TextField {
                                        id: textFieldCostItemName
                                        y: 50
                                        height: 50
                                        anchors.left: parent.left
                                        anchors.leftMargin: 147
                                        anchors.right: parent.right
                                        anchors.rightMargin: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        Label {
                                            id: labelCostItemNameWarning
                                            x: 0
                                            y: 47
                                            color: "#dd1037"
                                            text: qsTr("Это обязательное поле!")
                                            visible: false
                                        }
                                    }
                                }

                                Rectangle {
                                    id: rectangle3
                                    y: 46
                                    width: 639
                                    height: 175
                                    color: "#00000000"
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    Rectangle {
                                        id: rectangle4
                                        width: 640
                                        height: 1
                                        color: primaryColor
                                        anchors.topMargin: 0
                                        anchors.top: parent.top
                                    }

                                    Label {
                                        id: label2
                                        y: 67
                                        text: qsTr("Стоимость")
                                        textFormat: Text.PlainText
                                        anchors.verticalCenter: parent.verticalCenter
                                        Layout.rowSpan: 1
                                        anchors.leftMargin: 5
                                        Layout.columnSpan: 1
                                        anchors.left: parent.left
                                    }

                                    Rectangle {
                                        id: rectangle6
                                        width: 200
                                        color: "#00000000"
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 5
                                        anchors.top: parent.top
                                        anchors.topMargin: 5
                                        anchors.right: parent.right
                                        anchors.rightMargin: 5

                                        Label {
                                            id: label3
                                            x: -435
                                            text: qsTr("СУММА: ")
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 0
                                            font.capitalization: Font.AllUppercase
                                            font.bold: false
                                            horizontalAlignment: Text.AlignLeft
                                            renderType: Text.NativeRendering
                                            anchors.left: parent.left
                                            anchors.leftMargin: 0
                                        }

                                        Label {
                                            id: labelCost
                                            x: 68
                                            y: 149
                                            width: 104
                                            height: 16
                                            text: qsTr("0")
                                            horizontalAlignment: Text.AlignRight
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 0
                                            font.bold: false
                                            anchors.leftMargin: 63
                                            anchors.left: parent.left
                                        }

                                        RoundButton {
                                            id: buttonAddCostTerm
                                            x: 36
                                            width: 36
                                            height: 36
                                            autoExclusive: true
                                            autoRepeat: false
                                            checkable: false
                                            checked: false
                                            anchors.right: parent.right
                                            anchors.rightMargin: 0
                                            anchors.top: parent.top
                                            anchors.topMargin: 1

                                            Material.background: secondaryColor
                                            icon.source: iconAdd
                                            icon.width: width/2
                                            icon.height: height/2


                                        }

                                        TextField {
                                            id: textFieldCostTerm
                                            x: 66
                                            width: 168
                                            height: 42
                                            text: qsTr("")
                                            rightPadding: 13
                                            anchors.top: parent.top
                                            anchors.topMargin: 0
                                            font.pointSize: 11
                                            horizontalAlignment: Text.AlignRight
                                            anchors.left: parent.left
                                            anchors.leftMargin: 0
                                            //Настройка, чтобы при вводе появлялась клавиатура с цифрами
                                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        }

                                        ListView {
                                            id: listViewCostTerms
                                            height: 101
                                            boundsBehavior: Flickable.StopAtBounds
                                            highlightRangeMode: ListView.NoHighlightRange
                                            anchors.top: parent.top
                                            anchors.topMargin: 37
                                            anchors.right: parent.right
                                            anchors.rightMargin: -2
                                            anchors.left: parent.left
                                            anchors.leftMargin: 0
                                            orientation: ListView.Vertical
                                            //Необходимо включать это свойство, чтобы компонеты списка обезались его границами
                                            clip: enabled
                                        }

                                        Rectangle {
                                            id: rectangle5
                                            width: 202
                                            height: 1
                                            color: primaryColor
                                            anchors.top: parent.top
                                            anchors.topMargin: 143
                                            border.width: 2
                                            anchors.right: parent.right
                                            anchors.rightMargin: 32
                                            anchors.left: parent.left
                                            anchors.leftMargin: 0
                                        }
                                    }

                                    border.color: primaryColor
                                    border.width: 0
                                    anchors.leftMargin: 0
                                    anchors.left: parent.left
                                }

                                Rectangle {
                                    id: rectangle7
                                    y: 46
                                    width: 640
                                    height: 79
                                    color: "#00000000"
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.rightMargin: 0

                                    Rectangle {
                                        id: rectangle8
                                        width: 640
                                        height: 1
                                        color: primaryColor
                                        anchors.topMargin: 0
                                        anchors.top: parent.top
                                    }

                                    Label {
                                        id: label4
                                        y: 67
                                        text: qsTr("Обязательная трата")
                                        Layout.columnSpan: 1
                                        Layout.rowSpan: 1
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 5
                                        textFormat: Text.PlainText
                                    }

                                    Switch {
                                        id: switchNecessaryExpenditure
                                        x: 570
                                        y: 16
                                        text: qsTr("")
                                        checked: false
                                        anchors.verticalCenterOffset: 0
                                        anchors.right: parent.right
                                        anchors.rightMargin: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    anchors.leftMargin: 0
                                    border.width: 0
                                    border.color: primaryColor
                                }
                            }

                            Rectangle {
                                id: rectangleCostItemNames
                                x: 147
                                y: 113
                                width: textFieldCostItemName.width
                                height: 60
                                color: "#ffffff"
                                border.width: 0

                                visible: false

                                DropShadow {
                                    x: 0
                                    y: 0
                                    anchors.fill: rectangleCostItemNamesShadow
                                    horizontalOffset: 3
                                    verticalOffset: 3
                                    radius: 8.0
                                    visible: true
                                    samples: 17
                                    color: "#80000000"
                                    source: rectangleCostItemNamesShadow

                                }

                                Rectangle {
                                    id: rectangleCostItemNamesShadow
                                    color: "#ffffff"
                                    anchors.fill: parent

                                    ListView {
                                        id: listViewCostItemNames
                                        x: 0
                                        y: 0
                                        anchors.fill: parent
                                        boundsBehavior: Flickable.StopAtBounds
                                        clip: true

                                        visible: true

                                    }
                                }
                            }

                        }

                    }//pageCostItem

                }//itemExpenditure



                Item {
                    id: itemGraph

                    Page {
                        id: pageGraph
                        anchors.fill: parent

                        ScrollView {
                            id: scrollViewGraph
                            anchors.fill: parent
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                            clip: true
                            width: parent.width

                            /*!необходимо задавать ширину равной видимой ширине окна содержащего контент ScrollView,
                          иначе все элементы будут смещены*/
                            contentWidth: parent.width

                            Column {
                                id: column1
                                height: 400
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.right: parent.right
                                anchors.rightMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0

                                ChartView {
                                    id: chartMonthExpByType
                                    height: 250
                                    title: "Расходы за месяц по группам"
                                    titleFont.bold: true
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.left: parent.left
                                    anchors.leftMargin: 0
                                    antialiasing: true
                                    legend.alignment: Qt.AlignRight
                                    legend.visible: true
                                    legend.font.pixelSize: chartFontPixelSize

                                    PieSeries {
                                        id: pieSeriesMonthExpByType

                                    }//pieSeriesMonthExpByType

                                }//chartMonthExpByType

                                ChartView {
                                    id: chartMonthExpNec
                                    height: 300
                                    title: "Расходы за месяц по обязательности"
                                    titleFont.bold: true
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.left: parent.left
                                    anchors.leftMargin: 0
                                    antialiasing: true
                                    legend.alignment: Qt.AlignTop
                                    legend.font.pixelSize: chartFontPixelSize

                                    PieSeries {
                                        id: pieSeriesMonthExpByNec

                                    }//pieSeriesMonthExpByNec

                                }//chartMonthExpByNec


                                ChartView {
                                    id: chartYearExp
                                    height: pageGraph.height
                                    visible: true
                                    title: "Расходы по месяцам"
                                    titleFont.bold: true
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    anchors.left: parent.left
                                    anchors.leftMargin: 0
                                    antialiasing: true

                                    legend.alignment: Qt.AlignTop
                                    legend.font.pixelSize: chartFontPixelSize
                                    localizeNumbers: true

                                    BarCategoryAxis {
                                        id: barCategoryAxisYearExp
                                        labelsFont.pixelSize: chartFontPixelSize
                                        titleFont.pixelSize: chartFontPixelSize

                                        labelsAngle: 55


                                    }//BarCategoryAxis

                                    ValueAxis {
                                        id: valueAxisYearExp

                                        labelsFont.pixelSize: chartFontPixelSize

                                    }//valueAxisYearExp

                                    StackedBarSeries {
                                        id: stackedBarSeriesYearExp
                                        axisX: barCategoryAxisYearExp
                                        axisY: valueAxisYearExp

                                    }//stackedBarSeriesYearExp

                                }//chartYearExp
                            }
                        }//scrollViewGraph



                    }//pageGraph



                }//itemGraph

            }

            PageIndicator {
                id: pageIndicator


                anchors.bottom: swipeView.bottom
                anchors.horizontalCenter: parent.horizontalCenter


            }
        }
    }

    Rectangle {
        id: rectangleSplashScreen
        height: 0
        color: primaryColor
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top

        Image {
            id: imageSplashLogo
            height: parent.height/4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: iconLogo
            fillMode: Image.PreserveAspectFit
        }

        Label {
            id: label5
            x: 168.891
            y: 323
            color: "#ffffff"
            text: qsTr("мышка-жадюшка")
            anchors.verticalCenterOffset: 9
            font.underline: true
            anchors.verticalCenter: parent.verticalCenter
            visible: true
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 16
            font.bold: true
            font.family: "Verdana"
        }
    }


}

































/*##^##
Designer {
    D{i:60;anchors_height:160;anchors_width:488;anchors_x:142;anchors_y:114}D{i:59;anchors_height:200;anchors_width:200}
D{i:32;anchors_width:640}D{i:31;invisible:true}D{i:76;anchors_x:168.890625}D{i:74;anchors_height:0;anchors_width:200}
}
##^##*/
