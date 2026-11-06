import js from '@eslint/js';
import { defineConfig, globalIgnores } from 'eslint/config';
import globals from 'globals';

export default defineConfig([
  globalIgnores(['.venv', 'apm_modules', 'node_modules']),
  {
    files: ['**/*.mjs'],
    plugins: {
      js,
    },
    extends: [js.configs.recommended],
    rules: {
      'consistent-return': 'error',
      eqeqeq: 'error',
      'no-else-return': 'error',
      'prefer-const': 'error',
      'prefer-template': 'error',
      semi: 'error',
    },
  },
  {
    files: ['**/*.js'],
    plugins: {
      js,
    },
    extends: [js.configs.recommended],
    rules: {
      'consistent-return': 'error',
      eqeqeq: 'error',
      'no-else-return': 'error',
      semi: 'error',
    },
    languageOptions: {
      globals: globals.wsh,
    },
  },
]);
