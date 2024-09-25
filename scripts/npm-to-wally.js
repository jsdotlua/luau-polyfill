#!/usr/bin/env node

const { Command } = require("commander");

const fs = require("fs").promises;
const path = require("path");
const process = require("process");

const readPackageConfig = async (packagePath) => {
  const packageContent = await fs.readFile(packagePath).catch((err) => {
    console.error(`unable to read package.json at '${packagePath}': ${err}`);
    return null;
  });

  if (packageContent !== null) {
    try {
      const packageData = JSON.parse(packageContent);
      return packageData;
    } catch (error) {
      console.error(`unable to parse package.json at '${packagePath}': ${err}`);
    }
  }

  return null;
};

const packageWallyTranslation = {
  "luau-json": "seaofvoices/luau-json",
  "luau-task": "seaofvoices/luau-task",
};
const packageWallyVersionTranslation = {
  "seaofvoices/luau-task": { "1.0.0": "1.0.1" },
  "seaofvoices/luau-json": { "0.1.0": "0.1.1" },
};

const getWallyDependency = (npmPackageName, specifiedVersion) => {
  const wallyPackageName =
    packageWallyTranslation[npmPackageName] ?? `jsdotlua/${npmPackageName}`;

  if (specifiedVersion.startsWith("^")) {
    specifiedVersion = specifiedVersion.slice(1);
  }

  if (packageWallyVersionTranslation[wallyPackageName]) {
    if (packageWallyVersionTranslation[wallyPackageName][specifiedVersion]) {
      specifiedVersion =
        packageWallyVersionTranslation[wallyPackageName][specifiedVersion];
    }
  }

  return `"${wallyPackageName}@${specifiedVersion}"`;
};

const main = async (
  packageJsonPath,
  wallyOutputPath,
  rojoConfigPath,
  { workspacePath }
) => {
  const packageData = await readPackageConfig(packageJsonPath);

  const { name: scopedName, version, license, dependencies = [] } = packageData;

  const tomlLines = [
    "[package]",
    `name = "${scopedName.substring(1)}"`,
    `version = "${version}"`,
    'registry = "https://github.com/UpliftGames/wally-index"',
    'realm = "shared"',
    `license = "${license}"`,
    "",
    "[dependencies]",
  ];

  const rojoConfig = {
    name: "WallyPackage",
    tree: {
      $className: "Folder",
      Package: {
        $path: "src",
      },
    },
  };

  for (const [dependencyName, specifiedVersion] of Object.entries(
    dependencies
  )) {
    const name = dependencyName.startsWith("@")
      ? dependencyName.substring(dependencyName.indexOf("/") + 1)
      : dependencyName;

    rojoConfig.tree[name] = {
      $path: dependencyName + ".luau",
    };

    const wallyPackageName = name.indexOf("-") !== -1 ? `"${name}"` : name;

    if (specifiedVersion == "workspace:^") {
      const dependentPackage =
        workspacePath &&
        (await readPackageConfig(
          path.join(workspacePath, name, "package.json")
        ));

      if (dependentPackage) {
        tomlLines.push(
          `${wallyPackageName} = "jsdotlua/${name}@${dependentPackage.version}"`
        );
      } else {
        console.error(`unable to find version for package '${name}'`);
      }
    } else {
      const wallyDependency = getWallyDependency(
        dependencyName,
        specifiedVersion
      );

      tomlLines.push(`${wallyPackageName} = ${wallyDependency}`);
    }
  }

  tomlLines.push("");

  await Promise.all([
    fs.writeFile(wallyOutputPath, tomlLines.join("\n")).catch((err) => {
      console.error(
        `unable to write wally config at '${wallyOutputPath}': ${err}`
      );
    }),
    fs
      .writeFile(rojoConfigPath, JSON.stringify(rojoConfig, null, 2))
      .catch((err) => {
        console.error(
          `unable to write rojo config at '${rojoConfigPath}': ${err}`
        );
      }),
  ]);
};

const createCLI = () => {
  const program = new Command();

  program
    .name("npm-to-wally")
    .description("a utility to convert npm packages to wally packages")
    .argument("<package-json>")
    .argument("<wally-toml>")
    .argument("<package-rojo-config>")
    .option(
      "--workspace-path <workspace>",
      "the path containing all workspace members"
    )
    .action(
      async (packageJson, wallyToml, rojoConfig, { workspacePath = null }) => {
        const cwd = process.cwd();
        main(
          path.join(cwd, packageJson),
          path.join(cwd, wallyToml),
          path.join(cwd, rojoConfig),
          {
            workspacePath: workspacePath && path.join(cwd, workspacePath),
          }
        );
      }
    );

  return (args) => {
    program.parse(args);
  };
};

const run = createCLI();

run(process.argv);
