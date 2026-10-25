import pluginJs from '@eslint/js';
import globals from 'globals';
export default [
  pluginJs.configs.recommended,
  {
    ignores: ['.venv', 'node_modules', '**/Firefox/*', '**/Thunderbird/*'],
  },
  {
    files: ['**/*.js', '**/*.mjs'],
    rules: {
      'consistent-return': 'error',
      eqeqeq: 'error',
      'no-else-return': 'error',
      semi: 'error',
    },
  },
  {
    files: ['**/*.js'],
    languageOptions: {
      globals: {
        ...globals.wsh,
      },
      sourceType: 'script',
    },
  },
];
