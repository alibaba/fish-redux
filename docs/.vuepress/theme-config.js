const sidebar = require('./sidebar');
const nav = require('./nav');

module.exports = {
  nav: [
    // {
    //   text: '语言',
    //   items: [
    //     { text: '简体中文', link: '/' },
    //     { text: 'English', link: '/en/' },
    //   ],
    // },
  ],
  locales: {
    '/': {
      selectText: '多语言',
      label: '简体中文',
      editLinkText: 'Edit this page on GitHub',
      serviceWorker: {
        updatePopup: {
          message: '发现新内容可用',
          buttonText: '刷新',
        },
      },
      ...nav('zh'),
      ...sidebar('zh'),
    },
    // '/en/': {
    //   selectText: 'Languages',
    //   label: 'English',
    //   editLinkText: 'Edit this page on GitHub',
    //   serviceWorker: {
    //     updatePopup: {
    //       message: "New content is available.",
    //       buttonText: "Refresh"
    //     }
    //   },
    //   algolia: {},
    //   ...nav('en'),
    //   ...sidebar('en'),
    // },
  },
};
