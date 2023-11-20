#!/usr/bin/env node
import React from 'react';
import {render} from 'ink';
import meow from 'meow';
import App from './app';



const cli = meow(
	`
	Usage
	  $ sandbox-cli <path> <command>

	Options
		--name  Your name

	Examples
	  $ sandbox-cli --name=Jane
	  Hello, Jane
`,
	{
		importMeta: import.meta,
		flags: {
			name: {
				type: 'string',
			},
		},
	},
);

render(<App path={cli.input.at(0)||''} cmdState={cli.input.at(1)||''} />,  { patchConsole: false });