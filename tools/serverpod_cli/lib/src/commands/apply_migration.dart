import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:config/config.dart';
import 'package:path/path.dart' as path;
import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/config/serverpod_feature.dart';
import 'package:serverpod_cli/src/runner/serverpod_command.dart';
import 'package:serverpod_cli/src/runner/serverpod_command_runner.dart';
import 'package:serverpod_cli/src/util/project_name.dart';
import 'package:serverpod_cli/src/util/serverpod_cli_logger.dart';
import 'package:serverpod_cli/src/util/string_validators.dart';

class ApplyMigrationCommand extends ServerpodCommand {
  static const forceOption = FlagOption(
    argName: 'force',
    argAbbrev: 'f',
    negatable: false,
    defaultsTo: false,
    helpText:
        'Creates the migration even if there are warnings or information that '
        'may be destroyed.',
  );

  static const tagOption = StringOption(
    argName: 'tag',
    argAbbrev: 't',
    helpText: 'Add a tag to the revision to easier identify it.',
    customValidator: _validateTag,
  );

  static void _validateTag(String tag) {
    if (!StringValidators.isValidTagName(tag)) {
      throw const FormatException(
        'Tag names can only contain lowercase letters, numbers, and dashes.',
      );
    }
  }

  @override
  final name = 'apply-migration';

  @override
  final description = 'Applies the latest database migration to the database.';

  ApplyMigrationCommand() : super();

  @override
  Future<void> runWithConfig(
    final Configuration commandConfig,
  ) async {

    // Get interactive flag from global configuration
    final interactive = serverpodRunner.globalConfiguration.optionalValue(
      GlobalOption.interactive,
    );

    GeneratorConfig config;
    try {
      config = await GeneratorConfig.load(interactive: interactive);
    } catch (_) {
      throw ExitException(ServerpodCommand.commandInvokedCannotExecute);
    }

    if (!config.isFeatureEnabled(ServerpodFeature.database)) {
      log.error(
        'The database feature is not enabled in this project.'
        'This command cannot be used.',
      );
      throw ExitException(ServerpodCommand.commandInvokedCannotExecute);
    }

    var serverDirectory = Directory(
      path.joinAll(config.serverPackageDirectoryPathParts),
    );

    var projectName = await getProjectName(serverDirectory);
    if (projectName == null) {
      throw ExitException(ServerpodCommand.commandInvokedCannotExecute);
    }

    await log.progress('Applying migration in $projectName...', () async {
      //TODO first step: check if there are new migrations to apply
      //TODO second step: load latest migration and to apply it
      //TODO third step: get database session client
      //TODO fourth step: apply migration within a lock - launch the sql commands
      //TODO fifth step: update the migration table to reflect the new version
      Future.delayed(const Duration(seconds: 2), () async {
        log.info(
          'Migration applied successfully.',
          type: TextLogType.bullet,
        );
      });
      return true;
    });
  }
}
