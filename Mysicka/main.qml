import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.0
//
import mkm.qml.classes.monthlyexpenditure 1.0
import mkm.qml.classes.statistics 1.0


ApplicationWindow {
    id: appWindow
    visible: false
    width: 640
    height: 480
    title: qsTr("")

    //лоудер нужен, чтобы дождаться, когда загрузится форма, чтобы снизить вероятность мерцания приложения при старте
    //мерцание, скорее всего, происходит от того, что окно в начале не оптимального размера и требует перерисовки
    //чтобы механизм необходимо добавить нативный android splashscreen, который появится до старта приложения:
    /*1. В директорию "Mysicka/android/res/drawable/" добавляется файл splash.xml
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
          <style name="AppTheme">
              <item name="android:windowBackground">@drawable/splash</item>
          </style>
      </resources>

      2. В /Mysicka/android/res/values/ добавляется файл apptheme.xml:
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
            <style name="AppTheme">
                <item name="android:windowBackground">@drawable/splash</item>
            </style>
        </resources>

       3. В AndroidManifest.xml вносятся правки:
          ...

          <activity android:configChanges="orientation|uiMode|screenLayout|screenSize|smallestScreenSize|keyboard|keyboardHidden" android:name="org.qtproject.qt5.android.bindings.QtActivity" android:label="Мышка-жадюшка" android:screenOrientation="unspecified" android:theme="@style/AppTheme" android:launchMode="singleTop">
          ...
            <!-- Splash screen -->
            <!-- meta-data android:name="android.app.splash_screen_drawable" android:resource="@drawable/logo"/ -->
            <!-- meta-data android:name="android.app.splash_screen_sticky" android:value="true"/ -->
            <meta-data android:name="android.app.splash_screen_drawable" android:resource="@drawable/splash"/>
            <!-- Splash screen -->

      */
    Loader {
        id: loaderApp

        anchors.fill: parent
        asynchronous: true
        opacity: 0

        source: "Page1.qml"
        onLoaded: {
            appWindow.visible= true
            loaderApp.opacity=1

        }//onLoaded

        Behavior on opacity { NumberAnimation { duration: 250 } }

    }//Loader

    Page1Form {
             anchors.fill: parent
             id: page


             //Дата отчетного периода.
             property var calcDate: new Date()

             /*Код траты (используется при нажатии на кнопку toolButtonApply карточки траты,
               для принятия решения о добавлении или обновлении записи):
               -1 - Создается запись о новой трате
               иначе код траты, в случае если трата редактируется
             */
             property int applyCostItemIndex: -1

             //Флаг реэима удаоения объектов из списка затрат
             property bool listViewExpenditureDeleteMode: false

             //Цвета для графика
             property var graphColors: ['#F44336', goodConditionsColor, '#FF9800', '#2196F3', '#9C27B0', '#FFEB3B', '#009688']

             //Высота строки списка названий трат
             property int rowCostItemNamesHeight: 30


             //Расчет стоимости по списку слогаемых
             function calcCostByTerms () {
                 var cost= 0
                 for (var i = 0; i <=  modelCostTerms.count-1; i++)
                     cost= cost + modelCostTerms.get(i).value

                 labelCost.text= Number(cost).toLocaleString(Qt.locale("ru_RU"))

             }//calcCostByTerms

             //Добавление расходной статьи из MonthlyExpenditure в listViewExpenditure по индексу
             //p_Index [in] - индекс затраты в списке класса MCMonthlyExpenditure
             function addCostItemFromMonthlyExpenditure (p_Index) {

                 var l_costItem = monthlyExpenditure.getCostItem(p_Index)
                 var l_textColor= contentTextColorDark

                 if (!l_costItem.NecessaryExpenditure)
                     l_textColor= alertColor

                 modelExpenditure.insert(p_Index, {
                                             "date": l_costItem.Date.toLocaleString(Qt.locale("ru_RU"), "dd.MM.yyyy"),
                                             "name": l_costItem.Name,
                                             "cost": l_costItem.Cost.toLocaleString(Qt.locale("ru_RU")),
                                             "backgroundColor": "#00000000",
                                             "textColor": l_textColor
                                         })

             }//addCostItemFromMonthlyExpenditure

             //Открытие карточки затраты
             //p_Index [in] - индекс затраты в списке класса MCMonthlyExpenditure:
             //               не задан - карточка открывается как для нового элемента, с пустыви полями
             //               иначе - заполяется значениями соответствующего элемента из списка класса MCMonthlyExpenditure
             function openPageCostItem (p_Index){

                 //Существующая трата
                 if ((p_Index > -1)&&(p_Index < monthlyExpenditure.CostItemsCount))
                 {
                     var l_costItem = monthlyExpenditure.getCostItem(p_Index)

                     comboBoxCostItemDate.currentIndex= l_costItem.Date.getDate()-1
                     textFieldCostItemName.text= l_costItem.Name

                     textFieldCostTerm.clear()
                     modelCostTerms.clear()
                     var l_costTerm= ""
                     for (var l_j = 0; l_j < l_costItem.CostTerms.length; l_j++)
                     {
                         if(l_costItem.CostTerms[l_j] ==="%")
                         {
                             modelCostTerms.insert(modelCostTerms.count, {"value": Number(l_costTerm)})
                             l_costTerm= ""

                             continue

                         }//if

                         l_costTerm= l_costTerm + l_costItem.CostTerms[l_j]

                     }//for


                     labelCost.text= l_costItem.Cost.toLocaleString(Qt.locale("ru_RU"))

                     switchNecessaryExpenditure.checked = l_costItem.NecessaryExpenditure

                     applyCostItemIndex= p_Index
                     listViewCostTerms.currentIndex= -1

                 }
                 //Новая трата
                 else
                 {
                     comboBoxCostItemDate.currentIndex= calcDate.getDate()-1

                     //comboBoxCostItemName.currentIndex= -1
                     textFieldCostItemName.text= ""

                     textFieldCostTerm.clear()
                     modelCostTerms.clear()
                     labelCost.text= "0"

                     switchNecessaryExpenditure.checked = false

                     applyCostItemIndex= -1

                 }//else

                 showPageCostItem (true)

             }//openPageCostItem

             //Включение/выключение режима удаления(выбора) в списке трат
             //p_Active [in] - true - режим, false - выключен
             function setListViewExpenditureDeleteMode (p_Active)
             {
                 buttonAddCostItem.icon.name= "Delete"
                 if (p_Active)
                     buttonAddCostItem.icon.source= iconDelete
                 else
                     buttonAddCostItem.icon.source= iconAdd


                 listViewExpenditureDeleteMode= p_Active
                 buttonCancelCostItemSel.visible= p_Active

             }//setListViewExpenditureDeleteMode

             //Функция отображения карточки затраты
             //p_Show [in] true - показать форму карточки затрат, false - скрыть
             function showPageCostItem (p_Show)
             {
                 if (p_Show)
                 {
                     toolButtonClose.visible= false
                     toolButtonApply.visible= true
                     toolButtonBack.visible= true
                     imageToolLogo.visible= false
                     rectangleMonth.height= 0
                     pageIndicator.visible= false
                     swipeView.interactive= false

                 }//if
                 else
                 {
                     toolButtonClose.visible= true
                     toolButtonApply.visible= false
                     toolButtonBack.visible= false
                     imageToolLogo.visible= true
                     rectangleMonth.height= 50
                     pageIndicator.visible= true
                     swipeView.interactive= true
                 }//else

                 labelCostItemNameWarning.visible= false

                 pageCostItem.visible= p_Show
                 setMainTitle ()

             }//ShowPageCostItem

             //Установка текущего заголовка в зависимости от открытой формы
             function setMainTitle ()
             {
                 if (pageCostItem.visible)
                 {
                     labelMainTitle.text= "трата"
                     return

                 }//else

                 switch (swipeView.currentIndex){
                     case 0:
                         labelMainTitle.text= "расходы"

                         break;

                     case 1:
                         labelMainTitle.text= "анализ"
                         break;
                 }//switch

             }//getMainTitle

             MCMonthlyExpenditure {
                 id: monthlyExpenditure

                 onTotalUpdated: page.labelTotalCost.text = p_Total.toLocaleString(Qt.locale("ru_RU"))

                 onBudgetUpdated: page.textFieldBudget.text = p_Budget.toLocaleString(Qt.locale("ru_RU"))


                 onOverspendUpdated: {

                     page.labelOverspend.text = p_Overspend.toLocaleString(Qt.locale("ru_RU"))

                     budgetStats.update(page.calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MM.yy"), monthlyExpenditure.Budget.toString(), p_Overspend.toString())

                     if (monthlyExpenditure.Budget== 0)
                     {
                         page.labelOverspendName.text= "Перерасход:"
                         page.labelOverspend.color= page.contentTextColorDark
                         page.labelTotalCost.color= page.contentTextColorDark

                         return

                     }//if

                     if (p_Overspend>= 0)
                     {
                         page.labelOverspendName.text= "Остаток:"

                         if (p_Overspend> 0.2*monthlyExpenditure.Budget)
                             page.labelOverspend.color= page.goodConditionsColor

                         else
                             page.labelOverspend.color= page.secondaryColorDark


                         page.labelTotalCost.color= page.contentTextColorDark


                     }//if
                     else
                     {
                         page.labelOverspendName.text= "Перерасход:"
                         page.labelOverspend.text= page.labelOverspend.text.replace("-","")

                         page.labelOverspend.color= page.alertColor

                         page.labelTotalCost.color= page.alertColor

                     }//else

                 }//onOverspendUpdated

                 onCostItemsUpdated: {
                     modelExpenditure.clear()

                     if (monthlyExpenditure.CostItemsCount > 0)
                         for (var l_i= 0; l_i< monthlyExpenditure.CostItemsCount; l_i++)
                             page.addCostItemFromMonthlyExpenditure (l_i)

                 }//onCostItemsUpdated

                 onCostItemUpdated: {
                     if (p_OldIndex!= p_NewIndex)
                         modelExpenditure.move(p_OldIndex, p_NewIndex, 1)

                     var l_costItem = monthlyExpenditure.getCostItem(p_NewIndex)
                     var l_textColor= page.contentTextColorDark

                     if (!l_costItem.NecessaryExpenditure)
                         l_textColor= page.alertColor

                     modelExpenditure.set(p_NewIndex, {
                                              "date": l_costItem.Date.toLocaleString(Qt.locale("ru_RU"), "dd.MM.yyyy"),
                                              "name": l_costItem.Name,
                                              "cost": l_costItem.Cost.toLocaleString(Qt.locale("ru_RU")),
                                              "textColor": l_textColor
                                          })

                 }//onCostItemUpdated

                 onExpenditureNamesUpdated: {

                     //Заполняем перечень названий трат
                     modelCostItemNames.clear();

                     var l_s= ""

                     for (var l_i = 0; l_i <=  p_Names.length; l_i++)
                         if (p_Names[l_i]!==";")
                             l_s= l_s + p_Names[l_i]
                         else
                         {
                             modelCostItemNames.insert(0, {"name": l_s})
                             l_s= ""
                         }//else


                 }//onExpenditureNamesUpdated

                 onStatUpdated: {

                     //Расчет процента для легенды графика
                     function calcLabelGraphPercent (p_Num)
                     {
                         return Number((p_Num/p_Total)*100).toFixed(0).toString()+"% "
                     }//calcLabelGraphPercent

                     page.pieSeriesMonthExpByType.clear()
                     page.pieSeriesMonthExpByNec.clear()

                     if (p_Names==="")
                         return

                     var l_ParamName= ""
                     var l_OtherValues= 0
                     var l_s= ""

                     for (var l_i = 0; l_i <=  p_Names.length; l_i++)
                     {
                         if ((p_Names[l_i]!==";")&&(p_Names[l_i]!=="="))
                             l_s= l_s + p_Names[l_i]
                         if (p_Names[l_i]==="=")
                         {
                             l_ParamName= l_s
                             l_s= ""
                         }//if
                         if (p_Names[l_i]===";")
                         {

                             if ((l_ParamName!=="Necessary")&&(l_ParamName!=="NotNecessary"))
                             {
                                 //Выводим только первые 6 затрат, которые больше 5%. Все остальные затраты суммируем и выводим, как "Прочие"
                                 if ((page.pieSeriesMonthExpByType.count=== page.graphColors.length-1)||(Number(l_s)/p_Total< 0.05))
                                     l_OtherValues= l_OtherValues+(Number(l_s))
                                 else
                                 {
                                     page.pieSeriesMonthExpByType.append(l_ParamName, Number(l_s))
                                     page.pieSeriesMonthExpByType.at(page.pieSeriesMonthExpByType.count-1).label= calcLabelGraphPercent (Number(l_s))+l_ParamName
                                     page.pieSeriesMonthExpByType.at(page.pieSeriesMonthExpByType.count-1).color= page.graphColors[page.pieSeriesMonthExpByType.count-1]
                                 }//else
                             }
                             else
                             {
                                 if(l_ParamName==="Necessary")
                                 {
                                     page.pieSeriesMonthExpByNec.append ("Обязательные", Number(l_s))
                                     page.pieSeriesMonthExpByNec.at(0).color= page.goodConditionsColor
                                     page.pieSeriesMonthExpByNec.at(0).label= calcLabelGraphPercent (Number(l_s))+"Обязательные"
                                 }//if
                                 if (l_ParamName==="NotNecessary")
                                 {
                                     page.pieSeriesMonthExpByNec.append ("Необязательные", Number(l_s))
                                     page.pieSeriesMonthExpByNec.at(1).color= page.alertColor
                                     page.pieSeriesMonthExpByNec.at(1).label= calcLabelGraphPercent (Number(l_s))+"Необязательные"
                                 }//if

                             }//else

                             l_ParamName= ""
                             l_s= ""
                         }//if
                     }//for

                     if (l_OtherValues>0)
                     {
                         page.pieSeriesMonthExpByType.append("Прочее", l_OtherValues)
                         page.pieSeriesMonthExpByType.at(page.pieSeriesMonthExpByType.count-1).label= calcLabelGraphPercent (l_OtherValues)+"Прочее"
                         page.pieSeriesMonthExpByType.at(page.pieSeriesMonthExpByType.count-1).color= page.graphColors[page.pieSeriesMonthExpByType.count-1]

                     }//if


                 }//onStatUpdated

             }//MonthlyExpenditure

             MCBudgetStats {
                 id: budgetStats

                 onUpdated: {
                     page.stackedBarSeriesYearExp.clear()
                     page.barCategoryAxisYearExp.clear()

                     page.valueAxisYearExp.max= p_maxExp
                     page.barCategoryAxisYearExp.categories= p_Months

                     page.stackedBarSeriesYearExp.append("Бюджет", p_Budgets)
                     page.stackedBarSeriesYearExp.at(page.stackedBarSeriesYearExp.count-1).color= page.goodConditionsColor
                     page.stackedBarSeriesYearExp.append("Перерасход", p_Overspends)
                     page.stackedBarSeriesYearExp.at(page.stackedBarSeriesYearExp.count-1).color= page.alertColor

                 }//onUpdated

             }//MCBudgetStats


             labelCalendar {

                 text: qsTr(calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MMMM yyyy"))

                 onTextChanged: {
                     monthlyExpenditure.SetYearAndMonth (calcDate.getFullYear().toString(),
                                                                    calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MM"));

                     budgetStats.setCurMonth(calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MM.yy"));


                     //Устанавливаем дату
                     labelCostItemDate.text= calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MM.yyyy")
                     //заполняем список дней выбранного месяца
                     costItemDateListModel.clear()

                     var l_maxDayInMonth= new Date (calcDate.getFullYear(), calcDate.getMonth()+1, 0).getDate();
                     var l_date= new Date (calcDate.getFullYear(), calcDate.getMonth(), 1);

                     for (var l_i = 1; l_i <= l_maxDayInMonth; l_i++)
                     {
                         l_date.setDate(l_i)

                         if (l_i<10)
                           costItemDateListModel.insert(costItemDateListModel.count, {"day": "0"+Number(l_i).toString()+" "+l_date.toLocaleDateString(Qt.locale("ru_RU"), "ddd")})
                         else
                           costItemDateListModel.insert(costItemDateListModel.count, {"day": Number(l_i).toString()+" "+l_date.toLocaleDateString(Qt.locale("ru_RU"), "ddd")})


                     }//for

                 }//onTextChanged



             }//labelCalendar

             buttonNextMonth {
                 onClicked: {
                     calcDate.setMonth(calcDate.getMonth()+1)
                     labelCalendar.text = calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MMMM yyyy")

                 }//onClicked

             }//buttonNextMonth

             buttonPreviousMonth {

                 onClicked: {
                     calcDate.setMonth(calcDate.getMonth()-1)
                     labelCalendar.text = calcDate.toLocaleDateString(Qt.locale("ru_RU"), "MMMM yyyy")

                 }//onClicked

             }//buttonPreviousMonth

             //Проверка корректности значения введенного бюджета
             function validateBudget () {

                 labelBudgetWarning.visible= false

                 if(textFieldBudget.text.trim()=="")
                 {
                     monthlyExpenditure.Budget= 0
                     textFieldBudget.text= Number(0).toLocaleString(Qt.locale("ru_RU"))
                     return

                 }//if

                 try
                 {
                   var l_Budget= Number.fromLocaleString(Qt.locale("ru_RU"), textFieldBudget.text.trim().replace(".",","))
                 }
                 catch (e)
                 {
                     labelBudgetWarning.visible= true
                     labelBudgetWarning.text= "Бюджет должен быть положительным числом!"
                     monthlyExpenditure.Budget= 0

                 }//catch

                 if (isNaN(Number(l_Budget)))
                 {
                     labelBudgetWarning.visible= true
                     labelBudgetWarning.text= "Бюджет должен быть положительным числом!"
                     monthlyExpenditure.Budget= 0

                     return
                 }//if

                 if (l_Budget< 0)
                 {
                     labelBudgetWarning.visible= true
                     labelBudgetWarning.text= "Бюджет должен быть положительным числом!"
                     monthlyExpenditure.Budget= 0

                     return
                 }//if

                 monthlyExpenditure.Budget= Number(l_Budget)
                 textFieldBudget.text= Number(l_Budget).toLocaleString(Qt.locale("ru_RU"))

             }//validateBudget

             textFieldBudget {
                 id: textFieldBudget

                 onAccepted: validateBudget()

                 onFocusChanged: validateBudget()

             }//textFieldBudjet


             listViewExpenditure {
                 id: listViewExpenditure

                 model: ListModel {
                     id: modelExpenditure

                     //!!! Тестовые данные
                     ListElement {
                         date: "01.11.17"
                         name: "Продукты"
                         cost: "3 245.80"
                         backgroundColor: "#00000000"
                         textColor: "#dd000000"
                         selected: false
                     }

                 }//modelExpenditure


                 delegate: Item {
                     id: delegateExpenditure
                     x: 5
                     anchors.left: parent.left
                     anchors.right: parent.right
                     height: 40
                     Row {
                         id: rowExpenditure
                         anchors.right: parent.right
                         anchors.left: parent.left
                         anchors.leftMargin: 0
                         spacing: 5

                         Rectangle {
                             id: rectExpenditure
                             height: delegateExpenditure.height
                             anchors.right: parent.right
                             anchors.left: parent.left
                             color: backgroundColor
                             radius: 5
                             opacity: 0.7

                             //Дата
                             Text {
                                 id: textExpenditureDate
                                 text: date
                                 anchors.verticalCenter: parent.verticalCenter
                                 anchors.left: parent.left

                                 color: textColor
                             } //Дата

                             //Наименование
                             Text {
                                 id: textExpenditureName

                                 anchors.left: parent.left
                                 anchors.leftMargin: textExpenditureDate.width + rowExpenditure.spacing

                                 //Расчет оптимальной длинны поля
                                 width: (parent.width - 2 * rowExpenditure.spacing
                                         - textExpenditureDate.width) * 0.6
                                 text: name
                                 maximumLineCount: 2
                                 elide: Text.ElideRight
                                 wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                 anchors.verticalCenter: parent.verticalCenter

                                 color: textColor
                             } //Наименование

                             //Стоимость
                             Text {
                                 anchors.right: parent.right

                                 //Расчет оптимальной длинны поля
                                 width: (parent.width - 2 * rowExpenditure.spacing
                                         - textExpenditureDate.width) * 0.4
                                 text: cost
                                 elide: Text.ElideRight
                                 horizontalAlignment: Text.AlignRight
                                 wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                 font.bold: true
                                 anchors.verticalCenter: parent.verticalCenter

                                 color: textColor
                             } //Стоимость

                         }//Rectangle

                     }//Row

                     //Задержка открытия карточки затраты, чтобы появилось выделение при клике
                     Timer {
                         id: timerOpenPageCostItem
                         interval: 77

                         onTriggered: {

                             modelExpenditure.setProperty(index, "backgroundColor", "#00000000")
                             page.openPageCostItem (index)

                         }//onTriggered

                     }//Timer

                     MouseArea {
                         width: listViewExpenditure.width
                         height: parent.height

                         onClicked: {

                             if (page.listViewExpenditureDeleteMode)
                             {
                                 if (!modelExpenditure.get(index).selected)
                                 {
                                     modelExpenditure.setProperty(index, "selected", true)
                                     modelExpenditure.setProperty(index, "backgroundColor", page.secondaryColor)

                                 }//if
                                 else
                                 {
                                     modelExpenditure.setProperty(index, "selected", false)
                                     modelExpenditure.setProperty(index, "backgroundColor", "#00000000")

                                 }//else


                             }//if
                             else
                             {
                                 listViewExpenditure.currentIndex= index

                                 modelExpenditure.setProperty(index, "backgroundColor", page.secondaryColorLight)
                                 timerOpenPageCostItem.start()
                             }//else

                         }//onClicked

                         onPressAndHold: {
                             if (!page.listViewExpenditureDeleteMode)
                             {
                                 page.setListViewExpenditureDeleteMode(true)
                             }//if

                             onClicked(index)

                         }

                     }//MouseArea

                 }//delegateExpenditure

                 onFocusChanged: listViewExpenditure.currentIndex= -1

             }//listViewExpenditure

             buttonAddCostItem {

                 onClicked: {

                     if (!listViewExpenditureDeleteMode)
                         openPageCostItem ()
                     else
                     {
                         var l_i = 0
                         while (l_i< modelExpenditure.count)
                         {
                             if (modelExpenditure.get(l_i).selected)
                             {
                                 monthlyExpenditure.deleteCostItem(l_i)
                                 modelExpenditure.remove(l_i)

                             }//if
                             else
                                 l_i= l_i+1

                             if (modelExpenditure.count== 0)
                                 setListViewExpenditureDeleteMode(false)


                         }//while

                     }//else


                 }//onClicked

             }//buttonAddCostItem

             buttonCancelCostItemSel {
                 onClicked: {
                     for (var l_i=0; l_i< modelExpenditure.count;l_i++)
                         if (modelExpenditure.get(l_i).selected) {

                             modelExpenditure.setProperty(l_i, "selected", false)
                             modelExpenditure.setProperty(l_i, "backgroundColor", "#00000000")

                         }//if

                     setListViewExpenditureDeleteMode(false)

                 }//onClicked

             }//buttonCancelCostItemSel

             toolButtonClose {
                 onClicked:{
                     close()

                 }//onClicked

             }//toolButtonClose

             pageCostItem {
                 visible: false

             }//pageCostItem

             toolButtonBack {
                 onClicked: showPageCostItem (false)


             }//toolButtonBack

             toolButtonApply {
                 onClicked: {

                     if (textFieldCostItemName.text.trim()=="")
                     {
                        labelCostItemNameWarning.visible= true
                        return
                     }//if

                     //Если пользователь ввел сумму траты и не добавиле ее в список, сделаем это за него
                     if (textFieldCostTerm.text!== "")
                     {
                         var l_costTerm= textFieldCostTerm.text.trim().replace(",",".")

                         if ((!isNaN(Number(l_costTerm)))&&(Number(l_costTerm)!=0)&&(buttonAddCostTerm.icon.source == iconAdd))
                         {
                             modelCostTerms.insert(0, {"value": Number(l_costTerm)})
                             calcCostByTerms();
                         }//if


                     }//if

                     var l_costTerms= ""
                     for (var l_i = 0; l_i <=  modelCostTerms.count-1; l_i++)
                         l_costTerms= l_costTerms + modelCostTerms.get(l_i).value + "%"

                     var l_index

                     if ((applyCostItemIndex> -1)&&(applyCostItemIndex< monthlyExpenditure.CostItemsCount))
                     {
                         l_index= monthlyExpenditure.UpdateCostItem(applyCostItemIndex,
                                                                    Date.fromLocaleString (Qt.locale("ru_RU"), comboBoxCostItemDate.currentText + "." + labelCostItemDate.text, "dd ddd.MM.yyyy"),
                                                                    textFieldCostItemName.text.trim(),
                                                                    Number.fromLocaleString(Qt.locale("ru_RU"), labelCost.text),
                                                                    l_costTerms,
                                                                    switchNecessaryExpenditure.checked)



                     }//if

                     else
                     {
                         l_index= monthlyExpenditure.AddCostItem(Date.fromLocaleString (Qt.locale("ru_RU"), comboBoxCostItemDate.currentText + "." + labelCostItemDate.text, "dd ddd.MM.yyyy"),
                                                                 textFieldCostItemName.text.trim(),
                                                                 Number.fromLocaleString(Qt.locale("ru_RU"), labelCost.text),
                                                                 l_costTerms,
                                                                 switchNecessaryExpenditure.checked);

                         addCostItemFromMonthlyExpenditure (l_index)


                     }//else

                     showPageCostItem (false)

                 }//onClicked

             }//toolButtonBack

             comboBoxCostItemDate {
                 model: ListModel{
                     id: costItemDateListModel
                     ListElement { day: "01"}
                 }

             }//comboBoxCostItenDate


             //Таймер для отслеживания изменения состояния ввода названия траты
             Timer {
                 id: timerTextFieldCostItemName
                 interval: 7
                 repeat: true

                 property string dispalyText: ""

                 onTriggered: {

                     var l_i= 0

                     if (page.textFieldCostItemName.displayText.trim()==="")
                     {
                         for (l_i=0; l_i< modelCostItemNames.count; l_i++)
                             modelCostItemNames.setProperty(l_i,"backgroundColor", "#00000000")

                         return
                     }//if

                     page.labelCostItemNameWarning.visible= false

                     var l_GoToBeginnning= true
                     if (dispalyText=== page.textFieldCostItemName.displayText)
                         l_GoToBeginnning= false
                     else
                         dispalyText= page.textFieldCostItemName.displayText

                     var l_index= 0
                     for (l_i=0; l_i< modelCostItemNames.count; l_i++){
                         if (page.textFieldCostItemName.displayText.toUpperCase().trim() === modelCostItemNames.get(l_i).name.slice(0, page.textFieldCostItemName.displayText.trim().length).toUpperCase().trim())
                         {
                             modelCostItemNames.move(l_i, l_index, 1)
                             modelCostItemNames.setProperty(l_i,"backgroundColor", page.secondaryColor)

                             if(l_GoToBeginnning)
                                 page.listViewCostItemNames.positionViewAtBeginning()

                             l_index= l_index+1
                         }//if
                         else
                         {
                             modelCostItemNames.setProperty(l_i,"backgroundColor", "#00000000")

                         }//else
                     }//for


                 }//onTriggered

             }//timerTextFieldCostItemName


             textFieldCostItemName {

                 onEditingFinished: {
                     rectangleCostItemNames.visible= false
                     timerTextFieldCostItemName.stop()

                 }//onEditingFinished

                 onFocusChanged: {
                     if (textFieldCostItemName.focus)
                         return

                     rectangleCostItemNames.visible= false
                     timerTextFieldCostItemName.stop()

                 }//onFocusChanged

                 onPressed: {
                     if (modelCostItemNames.count===0)
                         return

                     var l_height= rectangleCostItemNames.parent.height - rectangleCostItemNames.y - 5


                     if (l_height< modelCostItemNames.count*rowCostItemNamesHeight)
                         rectangleCostItemNames.height= l_height
                     else
                         rectangleCostItemNames.height= modelCostItemNames.count*rowCostItemNamesHeight

                     listViewCostItemNames.positionViewAtBeginning()
                     rectangleCostItemNames.visible= true

                     timerTextFieldCostItemName.dispalyText= textFieldCostItemName.displayText
                     timerTextFieldCostItemName.start()

                 }//onPressed



             }//textFieldCostItemName

             buttonAddCostTerm {
                 onClicked: {
                     var l_costTerm= textFieldCostTerm.text.trim().replace(",",".")

                     if (isNaN(Number(l_costTerm)))
                     {
                         textFieldCostTerm.text= ""
                         return
                     }//if

                     if (Number(l_costTerm)==0)
                         return

                     if (buttonAddCostTerm.icon.source == iconCheck) {

                         modelCostTerms.setProperty(listViewCostTerms.currentIndex, "value", Number(l_costTerm))
                         calcCostByTerms ()

                         listViewCostTerms.currentIndex= -1
                     }//if
                     else {
                         modelCostTerms.insert(0, {"value": Number(l_costTerm)})

                         textFieldCostTerm.text= ""
                         buttonAddCostTerm.icon.source= iconAdd
                     }

                 }//onClicked

             }//buttonAddCostTerm

             listViewCostTerms {
                 id: listViewCostTerms

                 model: ListModel {
                     id: modelCostTerms
                     //индекс предыдущей выделенносй строки списка
                     property var prevCurrentItemIndex: -2

                     //!!!Тестовые данные
                     ListElement {
                         value: 700
                         textColor: "black"
                     }

                 }//model

                 delegate: Component {

                     id: delegateCostTerms

                     Item {
                         height: 40
                         width: listViewCostTerms.width

                         Row {
                             id: rowCostTerm
                             spacing: 10

                             anchors.right: parent.right
                             anchors.rightMargin: 0
                             anchors.left: parent.left
                             anchors.leftMargin: 0

                             Text {
                                 id: textCostTerm
                                 text: value
                                 font.bold: false
                                 font.pointSize: 10

                                 horizontalAlignment: Text.AlignRight
                                 elide: Text.ElideRight
                                 wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                 width: listViewCostTerms.width - parent.spacing
                                        - buttonDeleteCostTerm.width - 2
                                 anchors.verticalCenter: parent.verticalCenter

                             } //Text

                             RoundButton {
                                 id: buttonDeleteCostTerm
                                 width: 36
                                 height: 36
                                 font.pointSize: 9
                                 anchors.verticalCenter: parent.verticalCenter

                                 Material.background: page.secondaryColor
                                 icon.source: page.iconClose
                                 icon.width: width/2
                                 icon.height: height/2

                                 onClicked: {
                                     modelCostTerms.remove(index)
                                     listViewCostTerms.currentIndex= -1

                                 }//onClicked

                             } //Button


                         }//Row

                         MouseArea {
                             width: textCostTerm.width
                             height: parent.height

                             onClicked: {
                                 modelCostTerms.prevCurrentItemIndex= listViewCostTerms.currentIndex
                                 listViewCostTerms.currentIndex= index

                             }//onClicked

                         }//MouseArea

                     }//Item

                 }//delegateCostTerms


                 highlight: Component {
                     Rectangle {
                         radius: 5
                         color: page.secondaryColor

                     }

                 }//highlight

                 onCurrentIndexChanged: {
                     if (listViewCostTerms.currentIndex== -1) {

                         textFieldCostTerm.text= ""
                         buttonAddCostTerm.icon.source= iconAdd

                         //снимаем выделение
                         for (var i= 0; i<= modelCostTerms.count-1; i++)
                             modelCostTerms.setProperty(i, "textColor", "black")

                     }//if

                 }//onCurrentIndexChanged

                 onCountChanged: {

                     calcCostByTerms ()

                 }//onCountChanged

                 onCurrentItemChanged:{

                     //Убираем выделение при старте
                     if (modelCostTerms.prevCurrentItemIndex== -2) {

                         modelCostTerms.prevCurrentItemIndex= -1
                         listViewCostTerms.currentIndex= -1

                         return
                     }//if

                     textFieldCostTerm.text= modelCostTerms.get(listViewCostTerms.currentIndex).value
                     buttonAddCostTerm.icon.source= iconCheck


                 }//onCurrentItemChanged

             }//listViewCostTerms

             listViewCostItemNames {

                 model: ListModel {
                     id: modelCostItemNames

                     //!!!Тестовые данные
                     ListElement {
                         name: "Продукты"
                         backgroundColor: "#00000000"
                     }

                 }//modelCostItemNames

                 delegate: Component {

                     Item {
                         focus: true
                         height: page.rowCostItemNamesHeight
                         width: parent.width


                         Row {
                             spacing: 10
                             anchors.topMargin: 5
                             anchors.right: parent.right
                             anchors.rightMargin: 5
                             anchors.left: parent.left
                             anchors.leftMargin: 5

                             Rectangle {
                                 height: parent.parent.height
                                 anchors.right: parent.right
                                 anchors.left: parent.left

                                 color: backgroundColor
                                 opacity: 0.7

                                 Text {
                                     text: name
                                     font.bold: false
                                     font.pointSize: 12

                                     horizontalAlignment: Text.AlignLeft
                                     elide: Text.ElideLeft
                                     wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                     width: parent.width
                                     anchors.verticalCenter: parent.verticalCenter

                                 } //Text
                             }

                         }//Row


                         MouseArea {
                             anchors.fill: parent

                             onClicked: {
                                 page.textFieldCostItemName.text= modelCostItemNames.get(index).name
                                 page.listViewCostItemNames.focus= true

                             }//onClicked

                         }//MouseArea


                     }//Item
                 }//delegate

             }//listViewCostItemNames

             swipeView {
                 onCurrentIndexChanged: setMainTitle();

             }//swipeView

             pageIndicator {
                 count: swipeView.count
                 currentIndex: swipeView.currentIndex

             }//pageIndicator

             Timer{
                 id: timerSplashScreen
                 interval: 2000
                 running: true
                 triggeredOnStart: true

                 onTriggered:
                 {
                     if (page.rectangleSplashScreen.height===0)
                     {
                         page.rectangleSplashScreen.height= page.height

                     }
                     else
                         splashAnimation.start()

                 }//onTriggered

             }//timerSplashScreen

             rectangleSplashScreen {

                 NumberAnimation on height {
                     id: splashAnimation
                     running: timerSplashScreen.stop()
                     duration: 1000
                     from: page.height; to: 0

                     onStarted: {
                         page.labelLogo.anchors.verticalCenterOffset= 50

                     }

                     onFinished: {
                         page.labelLogo.anchors.verticalCenterOffset= 9

                     }

                 }//NumberAnimation


             }//rectangleSplashScreen


         }//Page1Form

}//ApplicationWindow
