import React, { FC, ReactElement, useState } from "react";
import { Box, Newline, Text } from "ink";
import { Form, FormProps } from "ink-form";
import SelectInput, { Item } from "ink-select-input";
import { Config, ConfigEdit, loadConfig } from "./Config";

type MenuProps = {
  onSelect: (item: Item<string>) => void;
};

const MenuItems = ({ onSelect }: MenuProps) => {
  const items: Item<string>[] = [
    {
      label: "Sandbox Config",
      value: "config",
    },
    {
      label: "Test",
      value: "test",
    },
    {
      label: "Exit",
      value: "exit",
    },
  ];

  return <SelectInput items={items} onSelect={onSelect} />;
};

export interface MenuItemProps {
  close: (page?: string | null) => void;
  config: Config;
}

const Test: React.FC<MenuItemProps> = ({ close }) => {
  setTimeout(() => {
    close();
  }, 1000);
  return (
    <>
      <Text>{`TestTest`}</Text>
    </>
  );
};

const Menu: React.FC<MenuItemProps> = ({ close }) => {
  return (
    <MenuItems
      onSelect={(item) => {
        if (item.value == "exit") process.exit();
        close(item.value);
      }}
    />
  );
};

const componentMap: { [key: string]: FC<MenuItemProps> } = {
  config: ConfigEdit,
  test: Test,
  menu: Menu,
};

type Props = {
  cmdState?: string;
  path: string;
};

export default function App({ path, cmdState = "" }: Props) {
  const [state, setState] = useState<string>(cmdState);

  const [config, setConfig] = useState<Config | null>(null);

  React.useEffect(() => {
    loadConfig().then(setConfig);
  }, []);

  React.useEffect(() => {
    if (state == "") setTimeout(() => setState("menu"), 1);
  }, [state]);

  const SelectedComponent = config ? componentMap[state] : null;

  return (
    <Box borderStyle="round" flexDirection="column" borderColor="greenBright">
      <Box justifyContent="center">
        <Text color="green" underline bold>
          {config ? config.sbas.name : ""}: {state}
        </Text>
      </Box>
      {SelectedComponent && config && (
        <SelectedComponent
          close={(page) => {
            console.clear();
            setState(page || "");
          }}
          config={config}
        />
      )}
      <Newline />
      <Text color="blueBright">{path}</Text>
    </Box>
  );
}
