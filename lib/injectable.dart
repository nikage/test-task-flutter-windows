import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injectable.config.dart';

@InjectableInit()
void configureDependencies() => GetIt.instance.init();

final DI = GetIt.instance;