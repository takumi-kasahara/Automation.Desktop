import globals from 'globals';
import pluginJs from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';
export default [
  pluginJs.configs.recommended,
  stylistic.configs.recommended,
  {
    ignores: [
      'node_modules',
      '**/Firefox/*',
      '**/Thunderbird/*',
    ],
  },
  {
    files: [
      '**/*.js',
      '**/*.mjs',
    ],
    rules: {
      '@stylistic/arrow-parens': ['error', 'as-needed'],
      '@stylistic/comma-dangle': ['error', 'always-multiline'],
      '@stylistic/no-multi-spaces': ['error', { 'ignoreEOLComments': true }],
      '@stylistic/quote-props': ['error', 'consistent'],
      '@stylistic/semi': ['error', 'always'],
      'consistent-return': 'error',
      'eqeqeq': 'error',
      'no-else-return': 'error',
      'quotes': ['error', 'single'],
      'semi': 'error',
    },
  },
  {
    files: [
      '**/*.js',
    ],
    languageOptions: {
      globals: [
        globals.wsh,
      ],
      sourceType: 'script',
    },
  },
];
