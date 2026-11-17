// Validates a yaml file against the schema version it declares, the way a CLI
// would use the bundle. Usage: node index.js <path/to/file.yaml>
const fs = require('node:fs');
const Ajv = require('ajv');
const yaml = require('js-yaml');
const index = require('@test-org-th/sample-schemas/schemas/index.json');

const file = process.argv[2];
const doc = yaml.load(fs.readFileSync(file, 'utf8'));
const kind = doc.component ? 'component' : 'service';
const fileName = kind === 'component' ? 'Component.json' : 'Service.json';
const version = doc.schema_version;

const known = index[kind].versions.map(v => v.version);
if (!known.includes(version)) {
  console.error(`${file}: no ${kind} schema ${version} (have ${known.join(', ')})`);
  process.exit(2);
}

const schema = require(`@test-org-th/sample-schemas/schemas/${version}/${fileName}`);
const validate = new Ajv({ allErrors: true }).compile(schema);

if (validate(doc)) {
  console.log(`${file}: valid against ${kind} schema ${version}`);
} else {
  console.log(`${file}: ${validate.errors.length} errors against ${kind} schema ${version}`);
  for (const e of validate.errors) console.log(`  ${e.instancePath || '/'} ${e.message}`);
  process.exit(1);
}
