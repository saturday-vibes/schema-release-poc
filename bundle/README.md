# @test-org-th/sample-schemas

Every released version of the sample component and service schemas, built
from the release tags of
[schema-release-poc](https://github.com/saturday-vibes/schema-release-poc).

```
schemas/index.json              versions per kind with tag and commit
schemas/v1.1.0/Component.json
schemas/v1.0.0/Service.json
```

```js
const index = require('@test-org-th/sample-schemas/schemas/index.json');
const latest = index.component.latest;
const schema = require(`@test-org-th/sample-schemas/schemas/${latest}/Component.json`);
```
