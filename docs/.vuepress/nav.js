const links = [
  'guide',
  'library',
  'examples',
];

const text = {
  zh: [ '指南' ,'库',  '最佳实践' ],
  en: [ 'Guide', 'Library', 'Examples' ],
};

module.exports = (locale) => ({
  nav: links.map((link, index) => ({ text: text[locale][index], link: `/${locale}/${link}/` })),
});
