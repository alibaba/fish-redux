const groupTitle = {
  zh: {
    usage: '使用',
    introduction: '介绍',
    advanced: '进阶',
    concept: '概念',
    getStarted: '入门',
    other: '其它',
  },
  en: {
    usage: 'Usage',
    introduction: 'Introduction',
    advanced: 'Advanced',
    concept: 'Concept',
    getStarted: 'Get Started',
    other: 'Other',
  },
};

module.exports = (locale) => ({
  sidebar: {
    [`/${locale}/guide/`]: [
      {
        title: groupTitle[locale].usage,
        collapsable: false,
        sidebarDepth: 1,
        children: [
          'introduction',
          'evolution',
          'mechanism',
          'other',  // 兼容性，更新日志，开发体验
          {
            title: groupTitle[locale].getStarted,
            collapsable: false,
            sidebarDepth: 1,
            children: [
              'get-started/installation',
              'get-started/page',
              'get-started/component',
              'get-started/dependencies',
              'get-started/middleware',
            ],
          },
          {
            title: groupTitle[locale].advanced,
            collapsable: false,
            sidebarDepth: 1,
            children: [
              'advanced/auto-dispose',
              'advanced/filter',
              'advanced/higher-effect',
              'advanced/on-error',
              'advanced/oop',
              'advanced/should-update',
              'advanced/widget-wrapper',
            ],
          },
        ],
      },
      {
        title: groupTitle[locale].concept,
        collapsable: false,
        sidebarDepth: 1,
        children: [
          'concept/component',
          'concept/page',
          'concept/connector',
          'concept/adapter',
          'concept/route',
          'concept/middleware',
        ],
      },
      {
        title: groupTitle[locale].other,
        collapsable: false,
        sidebarDepth: 1,
        children: [
          `other/difference-with-redux`,
        ],
      },
    ],
    [`/${locale}/library/`]: [
      {
        title: 'redux',
        collapsable: false,
        sidebarDepth: 1,
        children: [],
      },
      {
        title: 'redux_adapter',
        collapsable: false,
        sidebarDepth: 1,
        children: [],
      },
      {
        title: 'redux_aop',
        collapsable: false,
        sidebarDepth: 1,
        children: [],
      },
      {
        title: 'redux_connector',
        collapsable: false,
        sidebarDepth: 1,
        children: [
          `connector/ConnOp-class`,
          `connector/Reselect1-class`,
          `connector/Reselect2-class`,
          `connector/Reselect3-class`,
          `connector/Reselect4-class`,
          `connector/Reselect5-class`,
          `connector/Reselect6-class`,
        ],
      },
      {
        title: 'redux_component',
        collapsable: false,
        sidebarDepth: 1,
        children: [],
      },
      {
        title: 'redux_middleware',
        collapsable: false,
        sidebarDepth: 1,
        children: [],
      },
      {
        title: 'redux_routes',
        collapsable: false,
        sidebarDepth: 1,
        children: [],
      },
    ],
    [`/${locale}/examples/`]: [],
  },
});