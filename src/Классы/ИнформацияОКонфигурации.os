#Использовать logos
#Использовать xml-parser
#Использовать "../internal"

Перем _КаталогИсходников;

Перем _лог;
Перем _ФайлКонфигурации;
Перем _ЭтоФорматEDT;
Перем _СоставПодсистем;

#Область ОбработчикиСобытий

Процедура ПриСозданииОбъекта(Знач пКаталогИсходников)
	
	_лог = Логирование.ПолучитьЛог(ИмяЛога());
	_КаталогИсходников = ВыгрузкаКонфигурации.АбсолютныйПуть(пКаталогИсходников);
	
	_лог.Отладка("Абсолютный путь к исходникам: %1", _КаталогИсходников);

	Если ВыгрузкаКонфигурации.ЭтоВыгрузкаКонфигурации(_КаталогИсходников) Тогда
		
		_ФайлКонфигурации = ОбъединитьПути(_КаталогИсходников, "Configuration.xml");
		_ЭтоФорматEDT = Ложь;
		_лог.Отладка("Это выгрузка конфигурации. Файл конфигурации: %1", _ФайлКонфигурации);
		
	ИначеЕсли ВыгрузкаКонфигурации.ЭтоВыгрузкаЕДТ(_КаталогИсходников) Тогда
		
		_ФайлКонфигурации = ОбъединитьПути(_КаталогИсходников, "Configuration", "Configuration.mdo");
		_ЭтоФорматEDT = Истина;
		_лог.Отладка("Это выгрузка EDT. Файл конфигурации: %1", _ФайлКонфигурации);
		
	Иначе
		
		ВызватьИсключение "Не удалось определить тип выгрузки";
		
	КонецЕсли;
	
	Если Не ВыгрузкаКонфигурации.ФайлСуществует(_ФайлКонфигурации) Тогда
		
		ВызватьИсключение "Не найден файл Configuration.xml в каталоге " + _КаталогИсходников;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция ВерсияКонфигурации() Экспорт
	
	чтениеXML = Новый ЧтениеXML;
	
	чтениеXML.ОткрытьФайл(_ФайлКонфигурации);
	
	версияКонфигурации = Неопределено;
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента
			И ВРег(ЧтениеXML.Имя) = ВРег("Version") Тогда
			
			Если Не ЧтениеXML.Прочитать() Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			Если Не ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			версияКонфигурации = ЧтениеXML.Значение;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат версияКонфигурации;
	
КонецФункции

Функция ОбъектыПодсистемы(Знач пПодсистема,
		Знач пУчитыватьОбъектыПодчиненныхПодсистем = Ложь,
		Знач пУчитыватьОбъектыРодительскихПодсистем = Ложь) Экспорт
	
	Если _СоставПодсистем = Неопределено Тогда
		
		_СоставПодсистем = ПолучитьСоставПодсистем();
		
	КонецЕсли;
	
	соотОтобранныеОбъекты = Новый Соответствие;
	
	подсистема = ЗначениеСтруктуры(_СоставПодсистем, пПодсистема);
	
	Если подсистема = Неопределено Тогда
		
		_лог.Ошибка("Подсистема <%1> не найдена.", пПодсистема);
		Возврат Новый Массив;
		
	КонецЕсли;
	
	СкопироватьСоответствие(соотОтобранныеОбъекты, подсистема["_Объекты_"]);
	
	количествоДобавлено = соотОтобранныеОбъекты.Количество();
	
	_лог.Информация("Для %1 добавлено %2 объектов", пПодсистема, количествоДобавлено);
	
	Если пУчитыватьОбъектыПодчиненныхПодсистем Тогда
		
		СкопироватьСоответствие(соотОтобранныеОбъекты, подсистема["_ОбъектыСПодчиненными_"]);
		
		_лог.Информация("Для %1 добавлено %2 объектов из подчиненных подсистем",
			пПодсистема,
			соотОтобранныеОбъекты.Количество() - количествоДобавлено);

		количествоДобавлено = соотОтобранныеОбъекты.Количество();
		
	КонецЕсли;
	
	Если пУчитыватьОбъектыРодительскихПодсистем Тогда
		
		СкопироватьСоответствие(соотОтобранныеОбъекты, подсистема["_ОбъектыСРодителями_"]);
		
		_лог.Информация("Для %1 добавлено %2 объектов из родительских подсистем",
			пПодсистема,
			соотОтобранныеОбъекты.Количество() - количествоДобавлено);

			количествоДобавлено = соотОтобранныеОбъекты.Количество();
		
	КонецЕсли;
	
	сз = Новый СписокЗначений;
	
	Для каждого цОбъект Из соотОтобранныеОбъекты Цикл
		
		сз.Добавить(цОбъект.Ключ);
		
	КонецЦикла;
	
	сз.СортироватьПоЗначению();
	
	Возврат сз.ВыгрузитьЗначения();
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСоставПодсистем()
	
	составПодсистем = Новый Соответствие();
	составПодсистем.Вставить("_ОбъектыСПодчиненными_", Новый Соответствие);
	составПодсистем.Вставить("_Объекты_", Новый Соответствие);
	составПодсистем.Вставить("_ОбъектыСРодителями_", Новый Соответствие);
	
	подсистемыПервогоУровня = ПолучитьПодсистемыИзКонфигурации();
	_лог.Отладка("Прочитано %1 подсистем первого уровня", подсистемыПервогоУровня.Количество());
	
	ДобавитьСоставПодсистем(составПодсистем, подсистемыПервогоУровня, _КаталогИсходников);
	
	Возврат составПодсистем;
	
КонецФункции

Функция ПолучитьПодсистемыИзКонфигурации()
	
	массивПодсистем = Новый Массив;
	
	Если _ЭтоФорматEDT Тогда
		
		путьКЭлементам = "Configuration._Элементы";
		ключЭлемента = "subsystems";
		префикс = "Subsystem.";
		
	Иначе
		
		путьКЭлементам = "MetaDataObject._Элементы.Configuration._Элементы.ChildObjects";
		ключЭлемента = "Subsystem";
		префикс = "";
		
	КонецЕсли;
	
	ПроцессорXML = Новый СериализацияДанныхXML();
	
	РезультатЧтения = ПроцессорXML.ПрочитатьИзФайла(_ФайлКонфигурации);
	
	элементы = ЗначениеСтруктуры(РезультатЧтения, путьКЭлементам);
	
	Если элементы = Неопределено Тогда
		
		_лог.Ошибка("Не удалось прочитать файл %1. Не найдены сведения о подсистемах", _ФайлКонфигурации);
		
		Возврат массивПодсистем;
		
	КонецЕсли;
	
	Для каждого цЭлементФайла Из ОбеспечитьМассив(элементы) Цикл
		
		Для каждого цЭлемент Из цЭлементФайла Цикл
			
			Если цЭлемент.Ключ = ключЭлемента Тогда
				
				полноеИмяПодсистемы = цЭлемент.Значение; // Например, Subsystem.СтандартныеПодсистемы
				
				имяПодсистемы = Сред(полноеИмяПодсистемы, СтрДлина(префикс) + 1);
				
				_лог.Отладка("Чтение подсистем из %1. Добавлена подсистема <%2>", _ФайлКонфигурации, имяПодсистемы);
				массивПодсистем.Добавить(имяПодсистемы);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат массивПодсистем;
	
КонецФункции

Процедура ДобавитьСоставПодсистем(пСоставПодсистем, пМассивПодсистем, Знач пТекущийКаталогПодсистем)
	
	Для каждого цПодсистема Из пМассивПодсистем Цикл
		
		состав = ПрочитатьСоставПодсистемы(цПодсистема, пТекущийКаталогПодсистем);
		
		текСостав = Новый Соответствие;
		текСостав.Вставить("_Объекты_", Новый Соответствие);
		СоответствиеПоМассиву(текСостав["_Объекты_"], состав.Объекты);
		
		текСостав.Вставить("_ОбъектыСПодчиненными_", Новый Соответствие);
		СоответствиеПоМассиву(текСостав["_ОбъектыСПодчиненными_"], состав.Объекты);
		
		текСостав.Вставить("_ОбъектыСРодителями_", Новый Соответствие);
		СоответствиеПоМассиву(текСостав["_ОбъектыСРодителями_"], состав.Объекты);
		СкопироватьСоответствие(текСостав["_ОбъектыСРодителями_"], пСоставПодсистем["_ОбъектыСРодителями_"]);
		
		ДобавитьСоставПодсистем(текСостав, состав.Подсистемы, состав.Каталог);

		СкопироватьСоответствие(пСоставПодсистем["_ОбъектыСПодчиненными_"], текСостав["_ОбъектыСПодчиненными_"]);
		
		пСоставПодсистем.Вставить(цПодсистема, текСостав);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьСоставПодсистемы(Знач пИмяПодсистемы, Знач пТекущийКаталогПодсистемы)
	
	Если _ЭтоФорматEDT Тогда
		
		Возврат ПрочитатьСоставПодсистемыEDT(пИмяПодсистемы, пТекущийКаталогПодсистемы);
		
	Иначе
		
		Возврат ПрочитатьСоставПодсистемыКонфигуратора(пИмяПодсистемы, пТекущийКаталогПодсистемы);
		
	КонецЕсли;
	
КонецФункции

Функция ПрочитатьСоставПодсистемыEDT(Знач пИмяПодсистемы, Знач пТекущийКаталогПодсистемы)
	
	составПодсистемы = Новый Структура;
	составПодсистемы.Вставить("Имя", пИмяПодсистемы);
	составПодсистемы.Вставить("Каталог", ОбъединитьПути(пТекущийКаталогПодсистемы, "Subsystems", пИмяПодсистемы));
	составПодсистемы.Вставить("Объекты", Новый Массив);
	составПодсистемы.Вставить("Подсистемы", Новый Массив);
	
	описаниеПодсистемы = ОбъединитьПути(составПодсистемы.Каталог, пИмяПодсистемы + ".mdo");
	
	_лог.Отладка("Читаю состав подсистемы <%1> из файла %2", пИмяПодсистемы, описаниеПодсистемы);
	
	ПроцессорXML = Новый СериализацияДанныхXML();
	
	РезультатЧтения = ПроцессорXML.ПрочитатьИзФайла(описаниеПодсистемы);
	
	объектыФайла = ЗначениеСтруктуры(РезультатЧтения, "Subsystem._Элементы");
	
	Для каждого цЭлементФайла Из ОбеспечитьМассив(объектыФайла) Цикл
		
		Для каждого цЭлемент Из цЭлементФайла Цикл
			
			Если цЭлемент.Ключ = "content"
				И СтрНайти(цЭлемент.Значение, ".") > 0 Тогда // Объекты без точек - это идентификаторы, а не объекты.
				
				составПодсистемы.Объекты.Добавить(цЭлемент.Значение);
				_лог.Отладка("	Добавил в <%1> объект <%2>", пИмяПодсистемы, цЭлемент.Значение);
				
			КонецЕсли;
			
			Если цЭлемент.Ключ = "subsystems" Тогда
				
				составПодсистемы.Подсистемы.Добавить(цЭлемент.Значение);
				_лог.Отладка("	Добавил в <%1> подчиненную подсистему <%2>", пИмяПодсистемы, цЭлемент.Значение);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	_лог.Отладка("<%1>: Объектов: %2, Подсистем: %3",
		пИмяПодсистемы,
		составПодсистемы.Объекты.Количество(),
		составПодсистемы.Подсистемы.Количество());
	
	Возврат составПодсистемы;
	
КонецФункции

Функция ПрочитатьСоставПодсистемыКонфигуратора(Знач пИмяПодсистемы, Знач пТекущийКаталогПодсистемы)
	
	составПодсистемы = Новый Структура;
	составПодсистемы.Вставить("Имя", пИмяПодсистемы);
	составПодсистемы.Вставить("Каталог", ОбъединитьПути(пТекущийКаталогПодсистемы, "Subsystems", пИмяПодсистемы));
	составПодсистемы.Вставить("Объекты", Новый Массив);
	составПодсистемы.Вставить("Подсистемы", Новый Массив);
	
	описаниеПодсистемы = ОбъединитьПути(пТекущийКаталогПодсистемы, "Subsystems", пИмяПодсистемы + ".xml");
	
	_лог.Отладка("Читаю состав подсистемы <%1> из файла %2", пИмяПодсистемы, описаниеПодсистемы);
	
	объекты = Новый Массив;
	подчиненныеПодсистемы = Новый Массив;
	
	ПроцессорXML = Новый СериализацияДанныхXML();
	
	РезультатЧтения = ПроцессорXML.ПрочитатьИзФайла(описаниеПодсистемы);
	
	объектыФайла = ЗначениеСтруктуры(РезультатЧтения, "MetaDataObject._Элементы.Subsystem._Элементы.Properties.Content");
	подсистемыФайла = ЗначениеСтруктуры(РезультатЧтения, "MetaDataObject._Элементы.Subsystem._Элементы.ChildObjects");
	
	Для каждого цЭлементФайла Из ОбеспечитьМассив(объектыФайла) Цикл
		
		Для каждого цЭлемент Из цЭлементФайла Цикл
			
			Если СтрНайти(цЭлемент.Значение._Значение, ".") > 0 Тогда // Объекты без точек - это идентификаторы, а не объекты.
				
				составПодсистемы.Объекты.Добавить(цЭлемент.Значение._Значение);
				_лог.Отладка("	Добавил в <%1> объект <%2>", пИмяПодсистемы, цЭлемент.Значение._Значение);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Для каждого цЭлементФайла Из ОбеспечитьМассив(подсистемыФайла) Цикл
		
		Для каждого цЭлемент Из цЭлементФайла Цикл
			
			Если цЭлемент.Ключ = "Subsystem" Тогда
				
				составПодсистемы.Подсистемы.Добавить(цЭлемент.Значение);
				_лог.Отладка("	Добавил в <%1> подчиненную подсистему <%2>", пИмяПодсистемы, цЭлемент.Значение);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	_лог.Отладка("<%1>: Объектов: %2, Подсистем: %3",
		пИмяПодсистемы,
		составПодсистемы.Объекты.Количество(),
		составПодсистемы.Подсистемы.Количество());
	
	Возврат составПодсистемы;
	
КонецФункции

Процедура СоответствиеПоМассиву(пСоответствие, Знач пМассив)
	
	Для каждого цЭлемент Из пМассив Цикл
		
		пСоответствие.Вставить(цЭлемент, Истина);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура СкопироватьСоответствие(пПриемник, Знач пИсточник)
	
	Для каждого цЭлемент Из пИсточник Цикл
		
		пПриемник.Вставить(цЭлемент.Ключ, цЭлемент.Значение);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЗначениеСтруктуры(Знач пСтруктура, Знач пКлюч, Знач пЗначениеПоУмолчанию = Неопределено)
	
	массивКлючей = СтрРазделить(пКлюч, ".", Ложь);
	
	Если массивКлючей.Количество() = 0 Тогда
		
		Возврат пСтруктура;
		
	КонецЕсли;
	
	Если Не ТипЗнч(пСтруктура) = Тип("Структура")
		И Не ТипЗнч(пСтруктура) = Тип("Соответствие") Тогда
		
		Возврат пЗначениеПоУмолчанию;
		
	КонецЕсли;
	
	текКлюч = массивКлючей[0];
	
	Если ТипЗнч(пСтруктура) = Тип("Структура")
		И Не пСтруктура.Свойство(текКлюч) Тогда
		
		Возврат пЗначениеПоУмолчанию;
		
	КонецЕсли;
	
	Если ТипЗнч(пСтруктура) = Тип("Соответствие")
		И пСтруктура[текКлюч] = Неопределено Тогда
		
		Возврат пЗначениеПоУмолчанию;
		
	КонецЕсли;
	
	Если массивКлючей.Количество() = 1 Тогда
		
		Возврат пСтруктура[текКлюч];
		
	Иначе
		
		массивКлючей.Удалить(0);
		новКлюч = СтрСоединить(массивКлючей, ".");
		
		Возврат ЗначениеСтруктуры(пСтруктура[текКлюч], новКлюч, пЗначениеПоУмолчанию);
		
	КонецЕсли;
	
КонецФункции

Функция ОбеспечитьМассив(пЗначение)
	
	Если пЗначение = Неопределено Тогда
		
		Возврат Новый Массив;
		
	КонецЕсли;
	
	Если ТипЗнч(пЗначение) = Тип("Массив") Тогда
		
		Возврат пЗначение;
		
	Иначе
		
		массив = Новый Массив;
		массив.Добавить(пЗначение);
		
		Возврат массив;
		
	КонецЕсли;
	
КонецФункции

Функция ИмяЛога() Экспорт
	
	Возврат "oscript.app.cf_info";
	
КонецФункции

#КонецОбласти