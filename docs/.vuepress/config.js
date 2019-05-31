const themeConfig = require('./theme-config');

module.exports = {
  base: '/fish-redux/',
  title: 'Fish Redux Document',
  description: '',
  head: [
    ['link', { res: 'shortcut icon', href: '/favicon.ico'}],
  ],
  port: 8089,
  locales: {
    '/': {
      lang: 'zh-CN',
      title: 'Fish Redux',
      description: '',
    },
    '/en/': {
      lang: 'en-US',
      title: 'Fish Redux',
      description: '',
    },
  },
  themeConfig,
};
