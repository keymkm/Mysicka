//Чтобы была возможность использовать графики QChartView необходимо заменить QGuiApplication на QApplication
#include <QApplication>
#include <QQmlApplicationEngine>

#include "monthlyexpenditure.h"
#include "statistics.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    qmlRegisterType<MCMonthlyExpenditure>("mkm.qml.classes.monthlyexpenditure",1,0,"MCMonthlyExpenditure");
    qmlRegisterType<MCCostItem>("mkm.qml.classes.monthlyexpenditure",1,0,"MCCostItem");
    qmlRegisterType<MCBudgetStats>("mkm.qml.classes.statistics",1,0,"MCBudgetStats");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
