module.exports = (locale) => ({
  sidebar: {
    [`/${locale}/guide/`]: [
      `introduction`,
      `evolution-of-fish-redux`,
      `features`,
      {
        title: 'Redux',   // 必要的
        collapsable: false, // 可选的, 默认值是 true,
        sidebarDepth: 1,    // 可选的, 默认值是 1
        children: [
          `action`,
          `connector`,
          `reducer`,
          `middleware`,
        ],
      },
      {
        title: 'Component',
        collapsable: false,
        sidebarDepth: 1,
        children: [
          `view`,
          `reducer`,
          `effect`,
          `higher-effect`,
          `lifecycle`,
          `dependencies`,
          `dependent`,
          `should-update`,
          `on-error`,
          `filter`,
          `oop`,
          `widget-wrapper`,
          `page`,
        ],
      },
      {
        title: 'Adapter',
        path: `adapter/`,
        collapsable: false,
        sidebarDepth: 1,
        children: [
          `adapter/static-flow-adapter`,
          `adapter/dynamic-flow-adapter`,
          `adapter/custom-adapter`,
        ],
      },
      {
        title: 'Other',
        collapsable: true,
        sidebarDepth: 1,
        children: [
          `what's-the-diiference`,
          `what's-connector`,
          `mechanism`,
          `directory`,
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