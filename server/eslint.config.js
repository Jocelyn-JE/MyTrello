const js = require('@eslint/js');
const tseslint = require('@typescript-eslint/eslint-plugin');
const tsparser = require('@typescript-eslint/parser');
const globals = require('globals');

// Common TypeScript configuration
const baseTypeScriptConfig = {
    languageOptions: {
        parser: tsparser,
        parserOptions: {
            project: './tsconfig.json',
            tsconfigRootDir: __dirname
        }
    },
    plugins: {
        '@typescript-eslint': tseslint
    },
    rules: {
        'indent': ['error', 4],
        'no-unused-vars': 'off', // Disable base rule in favor of TypeScript rule
        '@typescript-eslint/no-unused-vars': [
            'error',
            {
                argsIgnorePattern: '^_',
                varsIgnorePattern: '^_',
                destructuredArrayIgnorePattern: '^_'
            }
        ]
    }
};

module.exports = [
    js.configs.recommended,
    {
        files: ['**/*.ts', '**/*.tsx'],
        ...baseTypeScriptConfig,
        languageOptions: {
            ...baseTypeScriptConfig.languageOptions,
            globals: {
                ...globals.node
            }
        }
    },
    {
        files: ['**/*.test.ts', '**/*.spec.ts'],
        ...baseTypeScriptConfig,
        languageOptions: {
            ...baseTypeScriptConfig.languageOptions,
            globals: {
                ...globals.node,
                ...globals.jest
            }
        }
    },
    {
        ignores: ['eslint.config.js', '.eslintrc.js']
    }
];
