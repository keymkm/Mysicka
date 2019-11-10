#include "statistics.h"

//MCBudgetStats
//------------------------------------------
double MCBudgetStats::CalcMaxExpenditure (const QStringList &p_Budgets, const QStringList &p_Overspends)
{
    if (p_Budgets.count()== 0)
        return 0;
    if (p_Budgets.count()== 1)
        return p_Budgets.at(0).toDouble()+p_Overspends.at(0).toDouble();

    double l_max= p_Budgets.at(0).toDouble()+p_Overspends.at(0).toDouble();
    for (int l_i= 1; l_i< p_Budgets.count(); l_i++)
        if (l_max< (p_Budgets.at(l_i).toDouble() + p_Overspends.at(l_i).toDouble()))
            l_max= p_Budgets.at(l_i).toDouble() + p_Overspends.at(l_i).toDouble();

    return l_max;


}//CalcMaxExpenditure

void MCBudgetStats::ShowStatistics ()
{
    if (m_CurrentMonth=="")
        return;

    if (m_Months.count()<= m_Period)
        emit updated(CalcMaxExpenditure (m_Budgets, m_Overspends), m_Months, m_Budgets, m_Overspends);
    else {
        QStringList l_Months;
        QStringList l_Budgets;
        QStringList l_Overspends;

        //Определяем положение текущего месяца в списке
        int l_index= -1;
        for (int l_i= 0; l_i< m_Months.count(); l_i++)
           if (m_CurrentMonth== m_Months.at(l_i))
           {
               l_index= l_i;
               break;

           }//if

        if (l_index== -1)
        {
            emit updated(CalcMaxExpenditure (l_Budgets, l_Overspends), l_Months, l_Budgets, l_Overspends);
            return;

        }//if

        int l_delta= (m_Period- 1)/2;
        int l_fin;
        int l_start;

        if (m_Months.count()-1 >= l_index+l_delta)
        {
            l_fin= l_index+l_delta;
            l_start= l_index-l_delta;

            if (l_start< 0)
            {
                l_start= 0;
                l_fin= m_Period-1;
            }//if

        }//if
        else
        {
            l_fin= m_Months.count()-1;
            l_start= (m_Months.count() - m_Period);
        }//else


        for (int l_i= l_start; l_i<= l_fin; l_i++)
        {
            l_Months.append(m_Months.at(l_i));
            l_Budgets.append(m_Budgets.at(l_i));
            l_Overspends.append(m_Overspends.at(l_i));

        }//for

        emit updated(CalcMaxExpenditure (l_Budgets, l_Overspends), l_Months, l_Budgets, l_Overspends);


    }//else


}//ShowStatistics

void MCBudgetStats::update (const QString p_Month, const QString p_Budget, const QString p_Overspend)
{
    //Если бюджет не задан, то не обрабатываем такие случаи
    if ((p_Budget.trimmed()=="")||(qFuzzyCompare(p_Budget.toDouble(),0.0)))
        return;

    QString l_Budget= p_Budget;
    QString l_Overspend= p_Overspend;

    //Нормализуем значения
    if (l_Overspend.toDouble()>=0)
    {
        l_Budget= QString::number(l_Budget.toDouble()-l_Overspend.toDouble());
        l_Overspend="0";

    }//if
    else
        l_Overspend= QString::number(-1*l_Overspend.toDouble());

    if (m_Months.count()==0)
    {
        m_Months.append(p_Month);
        m_Budgets.append(l_Budget);
        m_Overspends.append(l_Overspend);

    }//if
    else {
        bool l_updated= false;

        for (int l_i= 0; l_i< m_Months.count(); l_i++)
            if (m_Months[l_i]== p_Month)
            {
                m_Budgets[l_i]= l_Budget;
                m_Overspends[l_i]= l_Overspend;

                l_updated= true;
                break;
            }//if


        if (!l_updated)
            for (int l_i= 0; l_i< m_Months.count(); l_i++)
                if (QDate::fromString(p_Month, "MM.yy")< QDate::fromString(m_Months.at(l_i),"MM.yy"))
                {
                    m_Months.insert(l_i, p_Month);
                    m_Budgets.insert(l_i, l_Budget);
                    m_Overspends.insert(l_i, l_Overspend);

                    break;
                }//if

    }//else

    ShowStatistics ();

}//update


void MCBudgetStats::setCurMonth (const QString p_Month)
{
    m_CurrentMonth= p_Month;

    ShowStatistics ();

}//SetCurMonth


MCBudgetStats::MCBudgetStats (QObject *parent):
    QObject(parent)
{
    //Загружаем данные о бюджетах и перерасходах
    //Получаем список файлов с данными по расходам
    QDir l_Dir (mc_AppWorkFilesDir);

    if (!l_Dir.exists())
        return;

    QStringList l_SL;
    l_SL = l_Dir.entryList(QStringList() << "*.csv" << "*.CSV", QDir::Files);

    if (l_SL.count()==0)
        return;

    QString l_s="";
    int l_cnt= 0;

    //Считываем из файлов данные бюджетов и перерасходов
    for (int l_i= 0; l_i< l_SL.count(); l_i++)
    {
        QFile l_file (l_Dir.path()+"/"+l_SL.at(l_i));
        if (!l_file.open(QIODevice::ReadOnly | QIODevice::Text))
            return;

        QTextStream l_TS (&l_file);

        m_Months.append(QDate::fromString(l_SL.at(l_i).left(7),"yyyy-MM").toString("MM.yy"));

        l_cnt= 0;
        while (!l_TS.atEnd())
        {
            l_s= l_TS.readLine();
            if (l_s.contains("Бюджет",Qt::CaseInsensitive))
            {
                if (l_s.split(";").at(1).trimmed().size()>0)
                {
                    m_Budgets.append(l_s.split(";").at(1).trimmed());
                    l_cnt= l_cnt+1;
                }//if
            }//if
            if (l_s.contains("Перерасход",Qt::CaseInsensitive))
                if (l_s.split(";").at(1).trimmed().size()>0)
                {
                    m_Overspends.append(l_s.split(";").at(1).trimmed());
                    l_cnt= l_cnt+1;
                }//if
            if (l_cnt==2)
            {
                int l_index= m_Overspends.count()-1;
                if (m_Overspends.at(l_index).toDouble()>=0)
                {
                    m_Budgets[l_index]= QString::number(m_Budgets.at(l_index).toDouble()-m_Overspends.at(l_index).toDouble());
                    m_Overspends[l_index]="0";

                }//if
                else {
                    m_Overspends[l_index]= QString::number(-1*m_Overspends.at(l_i).toDouble());

                }//else

                break;
            }//if

        }//while

        l_file.close();

    }//for


}//MCBudgetStats
