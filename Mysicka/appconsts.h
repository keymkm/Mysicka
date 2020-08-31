#ifndef APPCONSTS_H
#define APPCONSTS_H


/*В этом модуле содержатся все константы и параметры приложения*/

#include <QString>
#include <QStandardPaths>

QString const mc_AppName= "Mysicka"/**< Название приложения*/;

QString const mc_AppWorkFilesDir= QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/"+mc_AppName;/**< Путь к дирректории с файлами приложения*/

const QString mc_ExpenditureNamesFile= "Expenditure.dict"; /**< Название файла для словаря затрат*/

#endif // APPCONSTS_H
