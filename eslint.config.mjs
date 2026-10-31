import js from '@eslint/js';
import { defineConfig, globalIgnores } from 'eslint/config';
import globals from 'globals';

export default defineConfig([
  js.configs.recommended,
  globalIgnores(['.venv', 'apm_modules', 'node_modules']),
  globalIgnores(['Firefox/*', 'Thunderbird/*']),
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
]);
