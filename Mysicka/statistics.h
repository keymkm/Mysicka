#ifndef STATISTICS_H
#define STATISTICS_H

#include <QObject>
#include <QString>
#include <QDir>
#include <QTextStream>
#include <QDate>
#include "appconsts.h"


/**
 * @brief Класс для хранения данных о бюджетах/перерасходах за все месяцы
 *
 */
class MCBudgetStats: public QObject
{
    Q_OBJECT

public:

    /**
     * @brief Задает текущий год и месяц учета расходов
     * @param p_Month - месяц в формате MM.yy
     */
    Q_INVOKABLE void setCurMonth (const QString p_Month);

    /**
     * @brief Задает текущий год и месяц учета расходов
     * @param p_Month - месяц в формате MM.yy
     * @param p_Budget - бюджет
     * @param p_Overspend - перерасход
     */
    Q_INVOKABLE void update (const QString p_Month, const QString p_Budget, const QString p_Overspend);

    /**
     * @brief Конструктор
     */
    explicit MCBudgetStats (QObject *parent = nullptr);

signals:
    /**
      * @brief Сигнал обновления данных бюджет/перерасход
      * @param[in] p_maxExp Максимальный расход за p_Months
      * @param[in] p_Months Список последних m_Period месяцев, в которые входит текущий месяц (m_CurrentMonth)
      * @param[in] p_Budgets Список бюджетов за p_Months
      * @param[in] p_Overspends Список перерасходов за p_Months
      */
    void updated (const double p_maxExp, const QStringList &p_Months, const QStringList &p_Budgets, const QStringList &p_Overspends);



private:
    QString m_CurrentMonth; /**< Текущий месяц в формате <MM.yy>*/
    QStringList m_Months;/**< Список месяцев*/
    QStringList m_Budgets;/**< Список бюджетов*/
    QStringList m_Overspends;/**< Список перерасходов*/
    //!!!Вынести в настройки
    int m_Period= 5;/**< Количество месяцев, за которые выдается статистика*/

    /**
     * @brief Выдача данных статистики за m_Period, в который входит
     */
    void ShowStatistics ();

    /**
     * @brief Расчет максимальной траты в выборке
     * @param[in] p_Budgets Список бюджетов
     * @param[in] p_Overspends Список перерасходов
     * @return максимальное значение из суммы по выборкам p_Budgets и p_Overspends (p_Budgets[i] + p_Overspends[i])
     */
    double CalcMaxExpenditure (const QStringList &p_Budgets, const QStringList &p_Overspends);

};//MCBudgetStats

#endif // STATISTICS_H
