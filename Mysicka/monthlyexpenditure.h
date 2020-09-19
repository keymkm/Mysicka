#ifndef MONTHLYEXPENDITURE_H
#define MONTHLYEXPENDITURE_H

#include <QObject>
#include <QString>
#include <QList>
#include <QDate>
#include <QDir>
#include <QSettings>
#include "appconsts.h"


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



//Структура расхода
/**
 * @brief Класс для хранения структуры расходной статьи
 */
class MCCostItem : public QObject
{
    Q_OBJECT

    //The Q_PROPERTY macro declares a property that could be accessed from QML!
    Q_PROPERTY (QDate Date READ GetDate)
    Q_PROPERTY (QString Name READ GetName)
    Q_PROPERTY (double Cost READ GetCost)
    Q_PROPERTY (QString CostTerms READ GetCostTerms)
    Q_PROPERTY (bool NecessaryExpenditure READ GetNecessaryExpenditure)

public:

    /**
     * @brief Возвращает дату
     * @return дата
     */
    QDate GetDate ();

    /**
     * @brief Возвращает название
     * @return Название
     */
    QString GetName ();

    /**
     * @brief Возвращает суммарную стоимость
     * @return Стоимость
     */
    double GetCost ();

    /**
     * @brief Возвращает слогаемые стоимости в формате <значение1>%<значение2>%...<значениеN>%
     * @return Слогаемые стоимости
     */
    QString GetCostTerms ();

    /**
     * @brief Возвращает признак обязательной траты
     * @return true - обязательная трата, false - необязательная трата
     */
    bool GetNecessaryExpenditure ();

    /**
     * @brief Установка значений атрибутов
     * @param[in] p_Date дата
     * @param[in] p_Name название
     * @param[in] p_Cost суммарная стоимость
     * @param[in] p_CostTerms слогаемые стоимости
     * @param[in] p_NecessaryExpenditure признак обязательной траты
     */
    void SetAttributes (QDate p_Date, QString p_Name, double p_Cost, QString p_CostTerms, bool p_NecessaryExpenditure);

    /**
     * @brief Конструктор
     */
    explicit MCCostItem (QObject *parent = nullptr);

private:
    QDate m_Date;/**< Дата*/

    QString m_Name;/**< Наименование*/

    double m_Cost;/**< Стоимость*/

    QString m_CostTerms;/**< Слогаемые стоимости в формате <значение1>%<значение2>%...<значениеN>%*/

    bool m_NecessaryExpenditure;/**< Обязательная трата*/

};//MCCostItem

/**
 * @brief Класс для хранения данных о расходах за месяц
 *
 */
class MCMonthlyExpenditure : public QObject
{
    Q_OBJECT

public:
    //The Q_PROPERTY macro declares a property that could be accessed from QML!
    Q_PROPERTY (double Budget READ GetBudget WRITE SetBudget)

    Q_PROPERTY (double CostItemsCount READ GetCostItemsCount)

    /**
     * @brief Установка года и месяца учета расходов
     * @param p_Year - год в формате yyyy
     * @param p_Month - месяц в формате mm
     */
    Q_INVOKABLE void SetYearAndMonth (QString p_Year, QString p_Month);

    /**
     * @brief Добавление статьи расхода
     * @param[in] p_Date дата
     * @param[in] p_Name название
     * @param[in] p_Cost суммарная стоимость
     * @param[in] p_CostTerms слогаемые стоимости
     * @param[in] p_NecessaryExpenditure признак обязательной траты
     * @return индекс добавленной записи
     */
    Q_INVOKABLE int AddCostItem (const QDate &p_Date, const QString &p_Name, const double &p_Cost, const QString &p_CostTerms, const bool &p_NecessaryExpenditure= false);

    /**
     * @brief Обновление статьи расхода
     * @param[in] p_Index индекс статьи расхода
     * @param[in] p_Date дата
     * @param[in] p_Name название
     * @param[in] p_Cost суммарная стоимость
     * @param[in] p_CostTerms слогаемые стоимости
     * @param[in] p_NecessaryExpenditure признак обязательной траты
     * @return индекс добавленной записи
     */
    Q_INVOKABLE int UpdateCostItem (const int p_Index, const QDate &p_Date, const QString &p_Name, const double &p_Cost, const QString &p_CostTerms, const bool &p_NecessaryExpenditure);

    /**
     * @brief Удалить статью расхода
     * @param[in] p_Index индекс статьи расхода
     */
    Q_INVOKABLE void deleteCostItem (const int p_Index);

    /**
     * @brief Удаление названия затраты из списка/словаря
     * @param[in] p_Name - название затраты
     */
    Q_INVOKABLE void deleteExpenditureName (const QString p_Name);

    /**
     * @brief Сохранение в файл всех данных о расходах за месяц
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString SaveToFile ();

    /**
     * @brief Загрузка данных о тратах за месяц (m_Year и m_Month)
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString LoadFromFile ();

    /**
     * @brief Получение статьи расхода по индексу
     * @param[in] p_Index индекс в списке
     */
    Q_INVOKABLE MCCostItem* getCostItem (int p_Index);

    /**
     * @brief Получение месячного бюджета (m_Budget)
     */
    double GetBudget ();

    /**
     * @brief Установка месячного бюджета (m_Budget)
     */
    void SetBudget (double p_Budjet);

    /**
     * @brief Получение количества расходов
     * @return количестов расходов (количество элементов в списке m_CostItems)
     */
    int GetCostItemsCount ();

    /**
     * @brief Конструктор.
     */
    explicit MCMonthlyExpenditure (QObject *parent = nullptr);

signals:
    /**
     * @brief Сигнал обновления расхода за месяц (m_Total).
     */
    void totalUpdated (const double &p_Total);

    /**
     * @brief Сигнал обновления Бюджета (m_Budget).
     */
    void budgetUpdated (const double &p_Budget);

    /**
     * @brief Сигнал обновления Перерасхода (m_Overspend).
     */
    void overspendUpdated (const double &p_Overspend);

    /**
     * @brief Сигнал обновления Списка расходов (m_CostItems).
     */
    void costItemsUpdated ();

    /**
     * @brief Сигнал обновления статьи расхода (m_CostItems->at(p_Index)).
     */
    void costItemUpdated (const int &p_OldIndex, const int &p_NewIndex);

    /**
      * @brief Сигнал обновления списка имен
      * @param[in] p_Names Список расходов в формате "<название 1><;><название 2><;>...<название N><;>"
      */
    void expenditureNamesUpdated (const QString &p_Names);

    /**
      * @brief Сигнал обновления параметров статистики за месяц
      * @param[in] p_StatParams Список параметров статистики в формате "<Параметр 1>=<Значение><;><Параметр 2>=<Значение><;>...<Параметр N>=<Значение><;>"
      * @param[in] p_Total
      */
    void statUpdated(const QString &p_Names, const double &p_Total);

    /**
      * @brief Сигнал возникновения ошибки
      * @param[in] p_Type Тип ошибки:
      * 0 - ошибка (error)
      * 1 - предупреждение (warning)
      *
      * @param[in] p_Code Код ошибки или функция, в которой произошла ошибка
      * @param[in] p_Message Текст сообщения
      */
    void errorRaised (const int &p_Type, const QString &p_Code, const QString &p_Message);

private:
    QString m_Year;/**< Год. Используется для поиска и определения периода учета расходов, сохранения и загрузки данных за этот период*/

    QString m_Month;/**< Месяц. Используется для поиска и определения периода учета расходов, сохранения и загрузки данных за этот период*/

    double m_Total;/**< Итого - расход за месяц*/

    double m_Budget;/**< Бюджет*/

    double m_DefaultBudget;/**< Бюджет по умолчанию, который загружается из настроек*/

    double m_Overspend/**< Перерасход*/;

    QList <MCCostItem*> m_CostItems/**< Список расходов*/;

    QDir m_FilesDir;/**< Путь к папке с файлами*/

    QString m_MonthlyExpenditureFileName;/**< Название файла с затратами*/

    QStringList m_ExpenditureNames;/**< Список названий затрат*/

    QString m_StatFileName;/**< Название файла с затратами*/

    QStringList m_StatParams;/**< Список c данными статитстики затрат: сгруппированные (просуммированные) по имени и по необходимотси затраты. Формат: <Параметр>=<Значение>*/

    /**
     * @brief Обновление расхода за месяц (m_Total)
     * @param[in] p_NewCost новый расход
     */
    void UpdateTotal (double p_NewCost);

    /**
     * @brief Обновление перерасхода (m_Overspend)
     * @param[in] p_NewCost новый расход
     */
    void UpdateOverspend ();

    /**
     * @brief Очистка параметров - перевод их в изначальное состояние, кроме месяца и года
     */
    void ClearParams ();

    /**
     * @brief Добавление названия затраты в список/словарь
     * @param[in] p_Name - название затраты
     */
    void AddExpenditureName (QString p_Name);


    /**
     * @brief Загрузка названий трат из файла
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString LoadExpenditureNamesFromFile ();

    /**
     * @brief Сохранение названий трат в файл
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString SaveExpenditureNamesToFile ();

    /**
     * @brief Загрузка статистики из файла
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString LoadStatFromFile ();

    /**
     * @brief Рассчет параметров статистики за месяц. Перед началам рассчета все текущие параметры удаляются
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString CalcStatParams ();

    /**
     * @brief Обновление информации о статистике по тратам за месяц
     * @param p_Name - название траты
     * @param p_Cost - размер траты
     * @param p_NecessaryExpenditure - признак необходимости траты
     * @param p_SaveToFile - true - сохранять в файл параметры статистики, false - не сохранять
     * @return Если выполнено успешно, то "", иначе сообщение об ошибке
     */
    QString UpdateStatParams (QString p_Name, double p_Cost, bool p_NecessaryExpenditure, bool p_SaveToFile= true);


};//MCMonthlyExpenditure


#endif // MONTHLYEXPENDITURE_H
