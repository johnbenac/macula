/** @type {import('@commitlint/types').UserConfig} */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  ignores: [(msg) => /^Merge\b/i.test(msg)],
  rules: {
    'header-max-length': [2, 'always', 100],
    'body-empty': [2, 'never'],
    'body-leading-blank': [2, 'always'],
    'subject-empty': [2, 'never'],
    'type-empty': [2, 'never'],
    'type-case': [2, 'always', 'lower-case'],
  },
};
