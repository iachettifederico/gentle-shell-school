const { greeting } = require('./config');
const { format } = require('./format');

module.exports = (name) => format(name, greeting);
