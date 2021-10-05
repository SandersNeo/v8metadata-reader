#Использовать logos
#Использовать "../internal"

#Область ОписаниеПеременных

Перем _КэшПутей;
Перем _КэшСоответствий;
Перем _Лог;
Перем _КаталогИсходников;

Перем _ЭтоВыгрузкаКонфигуратора;
Перем _ЭтоВыгрузкаЕДТ;

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриСозданииОбъекта(Знач пКаталогИсходников)
	
	_КаталогИсходников = пКаталогИсходников;
	_лог = Логирование.ПолучитьЛог(ИмяЛога());
	
	ОпределитьТипВыгрузки();
	
	_КэшПутей = Новый Соответствие;
	
	_КэшСоответствий = Новый Структура;
	
	_КэшСоответствий.Вставить("Метаданные", СоответствиеМетаданнымКаталогам());
	_КэшСоответствий.Вставить("Модули", СоответствиеМодулейФайлам());
	
КонецПроцедуры

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция Путь(Знач пМетаданные) Экспорт
	
	путь = _КэшПутей.Получить(пМетаданные);
	
	Если ЗначениеЗаполнено(путь) Тогда
		Возврат путь;
	КонецЕсли;
	
	компоненты = СтрРазделить(пМетаданные, ".");
	
	Если компоненты.Количество() = 0 Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	компонентыПути = Новый Массив;
	компонентыПути.Добавить(_КаталогИсходников);
	
	// Тип метаданных
	имяМетаданных = ВРег(компоненты[0]);
	каталог = _КэшСоответствий.Метаданные[имяМетаданных];
	
	Если Не ЗначениеЗаполнено(каталог) Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	компонентыПути.Добавить(каталог);
	
	Если компоненты.Количество() = 2 Тогда // Передано в формате Метаданные.ИмяМетаданных
		
		имяФайла = _КэшСоответствий.Модули[ВРег(компоненты[1])];
		
		Если ЗначениеЗаполнено(имяФайла) Тогда
			
			Если _ЭтоВыгрузкаКонфигуратора Тогда
				
				компонентыПути.Добавить("Ext");
				
			КонецЕсли;
			
		Иначе
			
			Если _ЭтоВыгрузкаКонфигуратора Тогда

				имяФайла = компоненты[1] + ".xml";

			Иначе

				имяФайла = компоненты[1] + ".mdo";

			КонецЕсли;
			
		КонецЕсли;

		компонентыПути.Добавить(имяФайла);
		
		путь = СтрСоединить(компонентыПути, ПолучитьРазделительПути());
		
		_КэшПутей.Вставить(пМетаданные, путь);
		
		Возврат путь;
		
	КонецЕсли;
	
	Если компоненты.Количество() < 3 Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	// Имя объекта
	
	компонентыПути.Добавить(компоненты[1]);
	
	путь = ПутьПоПолномуМетаданному(пМетаданные, компонентыПути);
	
	_КэшПутей.Вставить(пМетаданные, путь);
	
	Возврат путь;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОпределитьТипВыгрузки()
	
	_ЭтоВыгрузкаКонфигуратора = ВыгрузкаКонфигурации.ЭтоВыгрузкаКонфигурации(_КаталогИсходников);
	_ЭтоВыгрузкаЕДТ = ВыгрузкаКонфигурации.ЭтоВыгрузкаЕДТ(_КаталогИсходников);
	
	_лог.Отладка("Это выгрузка конфигурации: " + _ЭтоВыгрузкаКонфигуратора);
	_лог.Отладка("Это выгрузка EDT: " + _ЭтоВыгрузкаЕДТ);
	
	Если (Не _ЭтоВыгрузкаЕДТ И Не _ЭтоВыгрузкаКонфигуратора)
		ИЛИ (_ЭтоВыгрузкаЕДТ И _ЭтоВыгрузкаКонфигуратора) Тогда
		
		ВызватьИсключение "Не удалось определить тип выгрузки";
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПутьПоПолномуМетаданному(пМетаданные, компонентыПути)
	
	компоненты = СтрРазделить(пМетаданные, ".");

	имяМетаданных = ВРег(компоненты[0]);
	типОбъекта = ВРег(компоненты[2]);
	
	имяФайла = _КэшСоответствий.Модули[типОбъекта];
	
	Если ЗначениеЗаполнено(имяФайла) Тогда
		
		Если _ЭтоВыгрузкаКонфигуратора Тогда
			
			компонентыПути.Добавить("Ext");
			
		КонецЕсли;
		
		компонентыПути.Добавить(имяФайла);
		
	ИначеЕсли имяМетаданных = "ОБЩАЯФОРМА" Тогда
		
		ДополнитьКомпоненты_МодульФормы(компонентыПути);
		
	ИначеЕсли типОбъекта = "ФОРМА" Тогда
		
		компонентыПути.Добавить("Forms");
		
		Если компоненты.Количество() > 3 Тогда
			
			компонентыПути.Добавить(компоненты[3]);
			
		КонецЕсли;
		
		Если компоненты.Количество() = 5
			И ВРег(компоненты[4]) = "ФОРМА" Тогда
			
			ДополнитьКомпоненты_Форма(компонентыПути);
			
		ИначеЕсли компоненты.Количество() > 5
			И ВРег(компоненты[4]) = "ФОРМА"
			И ВРег(компоненты[5]) = "МОДУЛЬ" Тогда
			
			ДополнитьКомпоненты_МодульФормы(компонентыПути);
			
		Иначе
			
			_лог.Предупреждение("Не поддерживаемый объект %1", пМетаданные);
			
		КонецЕсли;
		
	ИначеЕсли типОбъекта = "КОМАНДА" Тогда
		
		компонентыПути.Добавить("Commands");
		
		Если компоненты.Количество() > 3 Тогда
			
			компонентыПути.Добавить(компоненты[3]);
			
		КонецЕсли;
		
		Если компоненты.Количество() > 4 Тогда
			
			Если ВРег(компоненты[4]) = "МОДУЛЬКОМАНДЫ" Тогда
				
				Если _ЭтоВыгрузкаКонфигуратора Тогда
					
					компонентыПути.Добавить("Ext");
					
				КонецЕсли;
				
				компонентыПути.Добавить("CommandModule.bsl");
				
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		
		_лог.Предупреждение("Не поддерживаемый объект %1", пМетаданные);
		
	КонецЕсли;
	
	Возврат СтрСоединить(компонентыПути, ПолучитьРазделительПути());

КонецФункции

Процедура ДополнитьКомпоненты_Форма(компонентыПути)
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		компонентыПути.Добавить("Ext");
		компонентыПути.Добавить("Form.xml");
		
	КонецЕсли;
	
	Если _ЭтоВыгрузкаЕДТ Тогда
		
		компонентыПути.Добавить("Form.form");
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДополнитьКомпоненты_МодульФормы(компонентыПути)
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		компонентыПути.Добавить("Ext");
		компонентыПути.Добавить("Form");
		
	КонецЕсли;
	
	компонентыПути.Добавить("Module.bsl");
	
КонецПроцедуры

Функция СоответствиеМетаданнымКаталогам()
	
	Соответствие = Новый Соответствие();
	
	Соответствие.Вставить("РегистрБухгалтерии", "AccountingRegisters");
	Соответствие.Вставить("AccountingRegister", "AccountingRegisters");
	
	Соответствие.Вставить("РегистрНакопления", "AccumulationRegisters");
	Соответствие.Вставить("AccumulationRegister", "AccumulationRegisters");
	
	Соответствие.Вставить("БизнесПроцесс", "BusinessProcesses");
	Соответствие.Вставить("BusinessProcess", "BusinessProcesses");
	
	Соответствие.Вставить("РегистрРасчета", "CalculationRegisters");
	Соответствие.Вставить("CalculationRegister", "CalculationRegisters");
	
	Соответствие.Вставить("Справочник", "Catalogs");
	Соответствие.Вставить("Catalog", "Catalogs");
	
	Соответствие.Вставить("ПланСчетов", "ChartsOfAccounts");
	Соответствие.Вставить("ChartOfAccounts", "ChartsOfAccounts");
	
	Соответствие.Вставить("ПланВидовРасчета", "ChartsOfCalculationTypes");
	Соответствие.Вставить("ChartOfCalculationTypes", "ChartsOfCalculationTypes");
	
	Соответствие.Вставить("ПланВидовХарактеристик", "ChartsOfCharacteristicTypes");
	Соответствие.Вставить("ChartOfCharacteristicTypes", "ChartsOfCharacteristicTypes");
	
	Соответствие.Вставить("ОбщаяГруппа", "CommandGroups");
	Соответствие.Вставить("CommandGroup", "CommandGroups");
	
	Соответствие.Вставить("ОбщийРеквизит", "CommonAttributes");
	Соответствие.Вставить("CommonAttribute", "CommonAttributes");
	
	Соответствие.Вставить("ОбщаяКоманда", "CommonCommands");
	Соответствие.Вставить("CommonCommand", "CommonCommands");
	
	Соответствие.Вставить("ОбщаяФорма", "CommonForms");
	Соответствие.Вставить("CommonForm", "CommonForms");
	
	Соответствие.Вставить("ОбщийМодуль", "CommonModules");
	Соответствие.Вставить("CommonModule", "CommonModules");
	
	Соответствие.Вставить("ОбщаяКартинка", "CommonPictures");
	Соответствие.Вставить("CommonPicture", "CommonPictures");
	
	Соответствие.Вставить("ОбщийМакет", "CommonTemplates");
	Соответствие.Вставить("CommonTemplate", "CommonTemplates");
	
	Соответствие.Вставить("Константа", "Constants");
	Соответствие.Вставить("Constant", "Constants");
	
	Соответствие.Вставить("Обработка", "DataProcessors");
	Соответствие.Вставить("DataProcessor", "DataProcessors");
	
	Соответствие.Вставить("ОпределяемыйТип", "DefinedTypes");
	Соответствие.Вставить("DefinedType", "DefinedTypes");
	
	Соответствие.Вставить("ЖурналДокумента", "DocumentJournals");
	Соответствие.Вставить("DocumentJournal", "DocumentJournals");
	
	Соответствие.Вставить("Нумератор", "DocumentNumerators");
	
	Соответствие.Вставить("Документ", "Documents");
	Соответствие.Вставить("Document", "Documents");
	
	Соответствие.Вставить("Перечисление", "Enums");
	Соответствие.Вставить("Enum", "Enums");
	
	Соответствие.Вставить("ПодпискаНаСобытие", "EventSubscriptions");
	Соответствие.Вставить("EventSubscription", "EventSubscriptions");
	
	Соответствие.Вставить("ПланОбмена", "ExchangePlans");
	Соответствие.Вставить("ExchangePlan", "ExchangePlans");
	
	Соответствие.Вставить("ВнешнийИсточник", "ExternalDataSources");
	Соответствие.Вставить("ExternalDataSource", "ExternalDataSources");
	
	Соответствие.Вставить("КритерийОтбора", "FilterCriteria");
	Соответствие.Вставить("FilterCriterion", "FilterCriteria");
	
	Соответствие.Вставить("ФункциональнаяОпция", "FunctionalOptions");
	Соответствие.Вставить("FunctionalOption", "FunctionalOptions");
	
	Соответствие.Вставить("ПарамертФункциональыхОпций", "FunctionalOptionsParameters");
	Соответствие.Вставить("FunctionalOptionsParameter", "FunctionalOptionsParameters");
	
	Соответствие.Вставить("HTTPСервис", "HTTPServices");
	Соответствие.Вставить("HTTPService", "HTTPServices");
	
	Соответствие.Вставить("РегистрСведений", "InformationRegisters");
	Соответствие.Вставить("InformationRegister", "InformationRegisters");
	
	Соответствие.Вставить("Язык", "Languages");
	
	Соответствие.Вставить("Отчет", "Reports");
	Соответствие.Вставить("Report", "Reports");
	
	Соответствие.Вставить("Роль", "Roles");
	Соответствие.Вставить("Role", "Roles");
	
	Соответствие.Вставить("РегламентноеЗадание", "ScheduledJobs");
	Соответствие.Вставить("ScheduledJob", "ScheduledJobs");
	
	Соответствие.Вставить("Последовательность", "Sequences");
	Соответствие.Вставить("Sequence", "Sequences");
	
	Соответствие.Вставить("ПараметрСеанса", "SessionParameters");
	Соответствие.Вставить("SessionParameter", "SessionParameters");
	
	Соответствие.Вставить("ХранилищеНастроек", "SettingsStorages");
	Соответствие.Вставить("SettingsStorage", "SettingsStorages");
	
	Соответствие.Вставить("ЭлементСтиля", "StyleItems");
	Соответствие.Вставить("StyleItem", "StyleItems");
	
	Соответствие.Вставить("Подсистема", "Subsystems");
	Соответствие.Вставить("Subsystem", "Subsystems");
	
	Соответствие.Вставить("Задача", "Tasks");
	Соответствие.Вставить("Task", "Tasks");
	
	Соответствие.Вставить("WebСервис", "WebServices");
	Соответствие.Вставить("WebService", "WebServices");
	
	Соответствие.Вставить("XDTOПакет", "XDTOPackages");
	Соответствие.Вставить("XDTOPackage", "XDTOPackages");
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		Соответствие.Вставить("Конфигурация", "Ext");
		Соответствие.Вставить("Configuration", "Ext");
		
	КонецЕсли;
	
	Если _ЭтоВыгрузкаЕДТ Тогда
		
		Соответствие.Вставить("Конфигурация", "Configuration");
		Соответствие.Вставить("Configuration", "Configuration");
		
	КонецЕсли;
	
	соотВРег = Новый Соответствие;
	
	Для Каждого цЭлемент Из Соответствие Цикл
		
		соотВРег.Вставить(ВРег(цЭлемент.Ключ), цЭлемент.Значение);
		
	КонецЦикла;
	
	Возврат соотВРег;
	
КонецФункции

Функция СоответствиеМодулейФайлам()
	
	Соответствие = Новый Соответствие();
	
	Соответствие.Вставить("МОДУЛЬОБЪЕКТА", "ObjectModule.bsl");
	Соответствие.Вставить("МОДУЛЬ", "Module.bsl");
	Соответствие.Вставить("МОДУЛЬМЕНЕДЖЕРА", "ManagerModule.bsl");
	Соответствие.Вставить("МОДУЛЬНАБОРАЗАПИСЕЙ", "RecordSetModule.bsl");
	Соответствие.Вставить("МОДУЛЬМЕНЕДЖЕРАЗНАЧЕНИЯ", "ValueManagerModule.bsl");
	Соответствие.Вставить("МОДУЛЬКОМАНДЫ", "CommandModule.bsl");
	Соответствие.Вставить("PACKAGE", "Package.bin");
	Соответствие.Вставить("МОДУЛЬОБЫЧНОГОПРИЛОЖЕНИЯ", "OrdinaryApplicationModule.bsl");
	Соответствие.Вставить("МОДУЛЬУПРАВЛЯЕМОГОПРИЛОЖЕНИЯ", "ManagedApplicationModule.bsl");
	Соответствие.Вставить("МОДУЛЬСЕАНСА", "SessionModule.bsl");
	Соответствие.Вставить("МОДУЛЬВНЕШНЕГОСОЕДИНЕНИЯ", "ExternalConnectionModule.bsl");
	
	Возврат Соответствие;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ИмяЛога() Экспорт
	Возврат "oscript.app.cf_info";
КонецФункции

#КонецОбласти
