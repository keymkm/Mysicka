#ifndef MKMANDROIDUTILS_H
#define MKMANDROIDUTILS_H


/**
 * @brief Запрос на доступ к носителю памяти (внешнюю или внутреннюю карто памяти) в Android.
 * В результате вызова функции появляется диалог запроса предоставления прав на доступ к памяти утройства
 * @return true - права предоставлены, иначе false
 */
bool checkAndroidExternalStoragePermission();

#endif // MKMANDROIDUTILS_H
