#include "monthlyexpenditure.h"
#include <QTextStream>
#include <QStandardPaths>

//MCCostItem
//----------------------------------------------------
QString MCCostItem::GetName ()
{
    return m_Name;

}//GetName

QDate MCCostItem::GetDate ()
{
    return m_Date;

}//GetDate

double MCCostItem::GetCost ()
{
    return m_Cost;

}//GetCost

QString MCCostItem::GetCostTerms ()
{
    return m_CostTerms;

}//GetCostTerms

bool MCCostItem::GetNecessaryExpenditure ()
{
    return m_NecessaryExpenditure;

}//GetNecessaryExpenditure

void MCCostItem::SetAttributes (QDate p_Date, QString p_Name, double p_Cost, QString p_CostTerms, bool p_NecessaryExpenditure)
{
    m_Date= p_Date;
    m_Name= p_Name;
    m_Cost= p_Cost;
    m_CostTerms= p_CostTerms;

    m_NecessaryExpenditure= p_NecessaryExpenditure;

}//SetAttributes

MCCostItem::MCCostItem (QObject *parent):
    QObject(parent)

{
    m_Name= "";
    m_Cost= 0;
    m_CostTerms= "";
    m_NecessaryExpenditure= false;

}//MCCostItem


//TMonthlyExpenditure
//----------------------------------------------------
int MCMonthlyExpenditure::GetCostItemsCount ()
{
    return m_CostItems.count();

}//GetCostItemsCount

void MCMonthlyExpenditure::ClearParams ()
{
    m_Total= 0;
    emit totalUpdated(m_Total);

    m_Budget= 0;
    emit budgetUpdated(m_Budget);

    m_Overspend= 0;
    emit overspendUpdated(m_Overspend);

    if (m_CostItems.count()> 0)
    {
        for (int l_i= 0; l_i< m_CostItems.count(); l_i++)
            delete m_CostItems.at(l_i);

        m_CostItems.clear();

    }//if

    emit costItemsUpdated();

}//ClearParams


void MCMonthlyExpenditure::SetBudget (double p_Budget)
{
    //Сохраняем в настройки бюджет по умолчанию
    if (!qFuzzyCompare(m_DefaultBudget, p_Budget))
    {
        m_DefaultBudget= p_Budget;

        QSettings l_Settings (m_FilesDir.path()+"/"+mc_AppName+".conf", QSettings::IniFormat);
        l_Settings.setValue("budget", m_DefaultBudget);

    }//if

    if (qFuzzyCompare(m_Budget, p_Budget))
        return;

    m_Budget= p_Budget;
    UpdateOverspend ();

    SaveToFile ();

}//SetBudjet

double MCMonthlyExpenditure::GetBudget ()
{
    return m_Budget;

}//GetBudjet

void MCMonthlyExpenditure::UpdateOverspend ()
{
    if (qFuzzyCompare(m_Budget,0.0))
        m_Overspend= 0;
    else
        m_Overspend= m_Budget - m_Total;

    emit overspendUpdated (m_Overspend);

}//UpdateOverspend


void MCMonthlyExpenditure::UpdateTotal (double p_NewCost)
{
    m_Total= m_Total + p_NewCost;

    emit totalUpdated(m_Total);
    UpdateOverspend ();

}//UpdateTotal


QString  MCMonthlyExpenditure::SaveToFile ()
{
    if (m_FilesDir.path()=="")
        return "Не возможно создать папку для хранения данных";

    QFile l_file(m_FilesDir.path()+"/"+m_MonthlyExpenditureFileName);
    if (!l_file.open(QIODevice::WriteOnly | QIODevice::Text))
        return "Ошибка записи в файл";

    QTextStream l_out(&l_file);

    l_out << QString::fromUtf8("Сумма;") << QString::number(m_Total) << "\n";
    l_out << QString::fromUtf8("Бюджет;") << QString::number(m_Budget) << "\n";
    l_out << QString::fromUtf8("Перерасход;") << QString::number(m_Overspend) << "\n";

    l_out << QString::fromUtf8("Дата;")
          << QString::fromUtf8("Трата;")
          << QString::fromUtf8("Стоимость;")
          << QString::fromUtf8("Детализация;")
          << QString::fromUtf8("Обязательная трата")
          << "\n";

    for (int l_i= 0; l_i<= m_CostItems.count()-1; l_i++)
       l_out << m_CostItems.at(l_i)->GetDate().toString("dd.MM.yyyy") << ";"
             << m_CostItems.at(l_i)->GetName() << ";"
             << QString::number(m_CostItems.at(l_i)->GetCost()) << ";"
             << m_CostItems.at(l_i)->GetCostTerms() << ";"
             << QString::number(m_CostItems.at(l_i)->GetNecessaryExpenditure())
             << "\n";

    return "";

}//SaveToFile

QString MCMonthlyExpenditure::LoadFromFile ()
{

    ClearParams();

    bool l_IsConverted= true;

    QFile l_file(m_FilesDir.path()+"/"+m_MonthlyExpenditureFileName);
    if (!l_file.exists())
    {

        if (m_DefaultBudget>= 0)
        {
            m_Budget= m_DefaultBudget;
            emit budgetUpdated(m_Budget);
            UpdateOverspend ();
        }//if

        return "";
    }//if

    QString l_ErrMsgTitle= "Ошибка чтения файла "+l_file.fileName();
    QString l_ErrMsgBody= "";

    if (!l_file.open(QIODevice::ReadOnly | QIODevice::Text))
        return l_ErrMsgTitle;

    QTextStream l_ts (&l_file);

    QString l_s= "";
    int l_cnt= 0;

    QDate l_Date;
    QString l_Name= "";
    double l_Cost;
    QString l_CostTerms= "";
    bool l_NecessaryExpenditure;

    while (!l_ts.atEnd())
    {
        l_s= l_ts.readLine();
        l_cnt= l_cnt + 1;

        int l_i= l_s.indexOf(";");
        if (l_i== -1)
        {
          l_ErrMsgBody= ": некорректная запись("+QString(l_cnt)+"): " + l_s;
          break;
        }//if

        switch (l_cnt)
        {
        //считываем сумму трат за месяц
        case 1:
        {

            m_Total= l_s.right(l_s.length()-l_i-1).toDouble(&l_IsConverted);
            if (!l_IsConverted)
                l_ErrMsgBody=  + ": не удалось считать траты за месяц: " + l_s;

            emit totalUpdated(m_Total);

            break;
        }//1

        //считываем бюджет
        case 2:
        {
            m_Budget= l_s.right(l_s.length()-l_i-1).toDouble(&l_IsConverted);
            if (!l_IsConverted)
                l_ErrMsgBody=  + ": не удалось считать бюджет: " + l_s;

            emit budgetUpdated (m_Budget);

            break;
        }//2

        //считываем перерасход
        case 3:
        {
            m_Overspend= l_s.right(l_s.length()-l_i-1).toDouble(&l_IsConverted);
            if (!l_IsConverted)
                l_ErrMsgBody=  + ": не удалось считать перерасход за месяц: " + l_s;

            emit overspendUpdated(m_Overspend);

            break;
        }//3

        }//switch

        if (l_ErrMsgBody!= "")
            break;

        //Если не дошли до таблицы со значениями, идем дальше
        if (l_cnt< 5)
            continue;

        //Парсим строки с тратами
        MCCostItem* l_CostItem= new MCCostItem(this);

        //Считываем дату
        l_Date= QDate::fromString(l_s.left(l_i),"dd.MM.yyyy");
        if (!l_Date.isValid())
        {
            delete l_CostItem;
            l_ErrMsgBody= + ": не удалось считать дату("+QString(l_cnt)+"): "+ l_s;
            break;

        }//if

        //Считываем название
        l_s.remove(0, l_i+1);
        l_i= l_s.indexOf(";");

        if (l_i== -1)
        {
          l_ErrMsgBody= ": некорректная запись("+QString(l_cnt)+"): " + l_s;
          break;
        }//if

        l_Name= l_s.left(l_i);

        if (l_Name== "")
        {
            delete l_CostItem;
            l_ErrMsgBody= + ": отсутствует название затраты ("+QString(l_cnt)+"): "+ l_s;
            break;

        }//if

        //Считываем стоимость
        l_s.remove(0, l_i+1);
        l_i= l_s.indexOf(";");

        if (l_i== -1)
        {
          l_ErrMsgBody= ": некорректная запись("+QString(l_cnt)+"): " + l_s;
          break;
        }//if

        if (l_s.left(l_i)== "")
            l_Cost= 0;
        else
        {
            l_Cost= l_s.left(l_i).toDouble(&l_IsConverted);

            if (!l_IsConverted)
            {
                delete l_CostItem;
                l_ErrMsgBody= + ": не удалось считать стоимость ("+QString(l_cnt)+"): "+ l_s;
                break;

            }//if

        }//else

        //Считываем детализцию (слогаемые) затраты
        l_s.remove(0, l_i+1);
        l_i= l_s.indexOf(";");

        if (l_i== -1)
        {
          l_ErrMsgBody= ": некорректная запись("+QString(l_cnt)+"): " + l_s;
          break;
        }//if

        l_CostTerms= l_s.left(l_i);

        if ((l_CostTerms.length()>0)&&(l_CostTerms.indexOf("%")== -1))
        {
            delete l_CostItem;
            l_ErrMsgBody= + ": не удалось считать детадизацию затраты("+QString(l_cnt)+"): "+ l_s;
            break;

        }//if

        //Считываем флаг обязательня трата
        l_s.remove(0, l_i+1);

        l_NecessaryExpenditure= l_s.toInt(&l_IsConverted);

        if (!l_IsConverted)
        {
            delete l_CostItem;
            l_ErrMsgBody= + ": не удалось считать признак обязательности ("+QString(l_cnt)+"): "+ l_s;
            break;

        }//if

        l_CostItem->SetAttributes(l_Date, l_Name, l_Cost, l_CostTerms, l_NecessaryExpenditure);
        m_CostItems.append(l_CostItem);

    }//while

    l_file.close();

    if (l_ErrMsgBody== "")
    {
        emit costItemsUpdated();
        return "";
    }//if

    //Если была ошибка
    ClearParams();
    return l_ErrMsgTitle + l_ErrMsgBody;

}//LoadFromFile

void MCMonthlyExpenditure::SetYearAndMonth (QString p_Year, QString p_Month)
{
    m_Year= p_Year;
    m_Month= p_Month;

    m_MonthlyExpenditureFileName= m_Year+"-"+m_Month+"_"+mc_AppName+".csv";

    m_StatFileName= m_Year+"-"+m_Month+"_"+mc_AppName+".stat";

    LoadFromFile ();

    LoadExpenditureNamesFromFile ();

    LoadStatFromFile ();

}//SetYearAndMonth

MCCostItem* MCMonthlyExpenditure::getCostItem (int p_Index)
{
    return m_CostItems.at(p_Index);

}//getCostItem


int MCMonthlyExpenditure::AddCostItem (const QDate &p_Date, const QString &p_Name, const double &p_Cost, const QString &p_CostTerms, const bool &p_NecessaryExpenditure)
{

    /*!!!Внимание
    Обязательно задавать Parent объекту, который будет передаваться в QML,
    иначе он может быть уничтожен гарбадж-коллектором QML, т.к.
    QML получит права на передаваемый объект, когда будет потерян
    фокус/завершена ф-я QML, в которой он использовался:

    m_CostItems.append(new MCCostItem()) - объект будет уничтожен
    m_CostItems.append(new MCCostItem(this)) - объект не будет уничтожен.

    источники: https://www.embeddeduse.com/2018/04/02/qml-engine-deletes-c-objects-still-in-use/
    http://doc.qt.io/qt-5/qqmlengine.html#ObjectOwnership-enum
    */

    MCCostItem* l_CostItem= new MCCostItem(this);
    l_CostItem->SetAttributes(p_Date, p_Name, p_Cost, p_CostTerms, p_NecessaryExpenditure);

    //данные за последнюю дату вставляем в начало списка
    int l_index= 0;

    if (m_CostItems.count()== 0)
        m_CostItems.append(l_CostItem);
    else
        for (l_index= 0; l_index< m_CostItems.count(); l_index++)
        {
            if (m_CostItems.at(l_index)->GetDate()<= p_Date)
            {
                m_CostItems.insert(l_index, l_CostItem);
                break;
            }//if

            if (l_index== m_CostItems.count()-1)
            {
                m_CostItems.append(l_CostItem);
                l_index= l_index+1;
                break;
            }//if

        }//for

    UpdateTotal (p_Cost);

    SaveToFile ();

    AddExpenditureName(p_Name);
    UpdateStatParams (p_Name, p_Cost, p_NecessaryExpenditure);

    return l_index;

}//AddCostItem

int MCMonthlyExpenditure::UpdateCostItem (const int p_Index, const QDate &p_Date, const QString &p_Name, const double &p_Cost, const QString &p_CostTerms, const bool &p_NecessaryExpenditure)
{
    MCCostItem* l_CostItem= m_CostItems.at(p_Index);

    UpdateTotal (p_Cost-l_CostItem->GetCost());

    int l_Index= p_Index;
    if ((m_CostItems.count()> 1)&&(l_CostItem->GetDate()!= p_Date))
    {
        l_Index= m_CostItems.count()-1;
        for (int l_i= m_CostItems.count()-1; l_i>= 0; l_i--)
        {
            if (p_Date>= m_CostItems.at(l_i)->GetDate())
                l_Index= l_i;
            else
                break;


        }//for

        m_CostItems.move(p_Index, l_Index);

    }//if

    if (l_CostItem->GetName()!= p_Name)
        AddExpenditureName(p_Name);

    if ((p_Name!=l_CostItem->GetName())||p_NecessaryExpenditure!=l_CostItem->GetNecessaryExpenditure())
    {
        l_CostItem->SetAttributes(p_Date, p_Name, p_Cost, p_CostTerms, p_NecessaryExpenditure);
        CalcStatParams();
    }//if
    else
    {
        UpdateStatParams (p_Name, p_Cost - l_CostItem->GetCost()/*Рассчитываем разницу для пересчета статистики*/, p_NecessaryExpenditure);
        l_CostItem->SetAttributes(p_Date, p_Name, p_Cost, p_CostTerms, p_NecessaryExpenditure);

    }//else


    SaveToFile ();

    emit costItemUpdated(p_Index, l_Index);

    return l_Index;


}//UpdateCostItem

void MCMonthlyExpenditure::deleteCostItem (const int p_Index)
{

    MCCostItem* l_CostItem= m_CostItems.at(p_Index);
    UpdateTotal ((-1)*l_CostItem->GetCost());
    UpdateStatParams (l_CostItem->GetName(), (-1)*l_CostItem->GetCost(), l_CostItem->GetNecessaryExpenditure());

    delete l_CostItem;
    m_CostItems.removeAt(p_Index);

    SaveToFile ();

}//deleteCostItem

void MCMonthlyExpenditure::AddExpenditureName (QString p_Name)
{
    for (int l_i= 0; l_i< m_ExpenditureNames.count(); l_i++)
        if (p_Name.trimmed().toUpper()==m_ExpenditureNames.at(l_i).trimmed().toUpper())
        {
            m_ExpenditureNames.removeAt(l_i);
            break;

        }//if

    m_ExpenditureNames.append(p_Name);

    QFile l_file(m_FilesDir.path()+"/"+mc_ExpenditureNamesFile);
    if (!l_file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;

    //!!! Более оптимально добавлять запись в начало файла, чем его полностью перезаписывать
    QTextStream l_out(&l_file);

    QString l_s= "";
    for (int l_i= 0; l_i< m_ExpenditureNames.count(); l_i++)
    {
       l_out << m_ExpenditureNames.at(l_i) << "\n";
       l_s= l_s + m_ExpenditureNames.at(l_i)+";";
    }//for

    if (l_s!="")
        emit expenditureNamesUpdated(l_s);

}//AddExpenditureName

QString MCMonthlyExpenditure::LoadExpenditureNamesFromFile ()
{
    //Если список не пустой, то значит данные уже загружались, нет смысла несколько раз загружать названия трат из файла
    if (m_ExpenditureNames.count()> 0)
        return "";

    QFile l_file(m_FilesDir.path()+"/"+mc_ExpenditureNamesFile);
    if (!l_file.exists())
        return "";

    if (!l_file.open(QIODevice::ReadOnly | QIODevice::Text))
        return  "Ошибка чтения файла "+m_FilesDir.path()+"/"+mc_ExpenditureNamesFile;


    QTextStream l_ts (&l_file);
    QString l_s="";
    while (!l_ts.atEnd())
    {
        m_ExpenditureNames.append(l_ts.readLine());
        l_s= l_s + m_ExpenditureNames.at(m_ExpenditureNames.count()-1)+ ";";
    }//while

    emit expenditureNamesUpdated(l_s);

    return "";

}//LoadExpenditureNamesFromFile

QString MCMonthlyExpenditure::CalcStatParams ()
{
    m_StatParams.clear();

    m_StatParams.append("Necessary=0");
    m_StatParams.append("NotNecessary=0");

    //Считаем статистику за месяц c нуля по затратам
    if (m_CostItems.count()>0)
    {
        MCCostItem* l_CostItem;
        bool l_SaveToFile= false;

        for (int l_i=0; l_i< m_CostItems.count();l_i++)
        {
            l_CostItem= m_CostItems.at(l_i);

            if (l_i== m_CostItems.count()-1)
                l_SaveToFile= true;

            UpdateStatParams (l_CostItem->GetName(), l_CostItem->GetCost(), l_CostItem->GetNecessaryExpenditure(), l_SaveToFile);

        }//for

        return "";

    }//if

    //Нет данных по затратам
    emit statUpdated("", m_Total);
    return "";

}//CalcStatParams

QString MCMonthlyExpenditure::UpdateStatParams (QString p_Name, double p_Cost, bool p_NecessaryExpenditure, bool p_SaveToFile)
{
    int l_i;
    QStringList l_SL;

    l_SL= m_StatParams.filter(p_Name, Qt::CaseInsensitive);

    //Считаем обязательные/необязательные траты
    if (p_NecessaryExpenditure)
        l_i= m_StatParams.count()-2;
    else
        l_i= m_StatParams.count()-1;

    m_StatParams[l_i]= m_StatParams.at(l_i).split("=").at(0)+"="+QString::number(m_StatParams.at(l_i).split("=").at(1).toDouble() + p_Cost);

    //Ищем такуюже трату и обновляем/добавляем значение
    if (l_SL.count()==0)
         m_StatParams.insert(0, p_Name+"="+QString::number(p_Cost));
    else
    {
        double l_StatValue;
        for (l_i= 0; l_i< m_StatParams.count(); l_i++)
            if (m_StatParams.at(l_i).contains(p_Name, Qt::CaseInsensitive))
            {
                l_StatValue= m_StatParams.at(l_i).split("=").at(1).toDouble() + p_Cost;
                if (qFuzzyCompare(l_StatValue, 0.0))
                    m_StatParams.removeAt(l_i);
                else
                    m_StatParams[l_i]= p_Name+"="+QString::number(m_StatParams.at(l_i).split("=").at(1).toDouble() + p_Cost);

                break;

            }//if

    }//else

    //Сортируем значения
    int l_j= 0;
    int l_swap= 0;
    for (l_i= 0; l_i< m_StatParams.count()-2; l_i++)
    {
        l_swap= 0;
        for (l_j= 0; l_j< m_StatParams.count()-l_i-3; l_j++)
            if (m_StatParams.at(l_j).split("=").at(1).toDouble()< m_StatParams.at(l_j+1).split("=").at(1).toDouble())
            {
                m_StatParams.swap(l_j, l_j+1);
                l_swap= 1;

            }//if

        if (l_swap==0)
            break;

    }//for

    if (p_SaveToFile)
    {
        QFile l_file(m_FilesDir.path()+"/"+m_StatFileName);
        if (!l_file.open(QIODevice::WriteOnly | QIODevice::Text))
            return "Ошибка записи в файл "+m_FilesDir.path()+"/"+m_StatFileName;

        QTextStream l_out(&l_file);
        for (l_i= 0; l_i< m_StatParams.count(); l_i++)
           l_out << m_StatParams.at(l_i) << "\n";


    }//if

    emit statUpdated(m_StatParams.join(";")+";", m_Total);
    return "";

}//UpdateStatParams

QString MCMonthlyExpenditure::LoadStatFromFile ()
{
    QFile l_file(m_FilesDir.path()+"/"+m_StatFileName);
    if (!l_file.exists())
    {
        CalcStatParams ();
        return "";

    }//if


    if (!l_file.open(QIODevice::ReadOnly | QIODevice::Text))
        return  "Ошибка чтения файла "+m_FilesDir.path()+"/"+m_StatFileName;

    QTextStream l_ts (&l_file);
    m_StatParams.clear();
    while (!l_ts.atEnd())
        m_StatParams << l_ts.readLine();

    l_file.close();

    emit statUpdated(m_StatParams.join(";")+";", m_Total);

    return "";

}//LoadStatFromFile

MCMonthlyExpenditure::MCMonthlyExpenditure(QObject *parent):
    QObject(parent)
{
    m_Year= "";
    m_Month= "";
    m_Total= 0;
    m_Budget= 0;
    m_DefaultBudget= -1;
    m_Overspend= 0;

    //!!!Небезопстное место, надо подумать, как обрабатывать не возможность создать директорию
    m_FilesDir= QDir (mc_AppWorkFilesDir);
    if (!m_FilesDir.exists())
    {
        if (!m_FilesDir.mkpath(m_FilesDir.absolutePath()))
            m_FilesDir.setPath("");
    }//if
    else
    {
        //Cчитываем бюджет из конфига
        bool l_IsConverted;

        QSettings l_Settings (m_FilesDir.path()+"/"+mc_AppName+".conf", QSettings::IniFormat);
        m_DefaultBudget= l_Settings.value("budget").toDouble(&l_IsConverted);

        if (!l_IsConverted)
            m_DefaultBudget= -1;

    }//else

}//MonthlyExpenditure

