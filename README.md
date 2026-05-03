# OpenShift Operator Catalog

> Operators, by yours truly

## Included Operators

- [OpenShift Upgrade Accelerator Operator](https://github.com/kenmoini/openshift-upgrade-accelerator-operator)
- [Java Keystore Operator](https://github.com/kenmoini/jks-operator)

## Deploy the Operator Catalog

```bash
oc apply -k https://github.com/kenmoini/openshift-operator-catalog/deploy/overlays/main/
```

## Adding Operators to the Catalog

As long as your bundles are pushed and published, all that you need to do to add an Operator Bundle to this Catalog is add it to the `olm-templates/` directory in a YAML file.  This uses the new OLM Template model.

Once the changes are merged into either the main or stable branches, or a semver tag that starts with `v*`, the GitHub Actions workflows will build the operator catalog and push.

The GitHub Actions will validate the files and add them to the Catalog.

The name can be anything, though it's suggested to be the name of your Operator - either `yml` or `yaml` extensions will work.

The format of the file is simple:

```yaml
---
schema: olm.template.basic
entries:
  # List of Channels
  - schema: olm.package
    name: openshift-upgrade-accelerator-operator
    defaultChannel: alpha
  # List of Package versions
  - schema: olm.channel
    package: openshift-upgrade-accelerator-operator
    name: alpha
    entries:
      - name: openshift-upgrade-accelerator-operator.v0.0.2
        replaces: openshift-upgrade-accelerator-operator.v0.0.1
      - name: openshift-upgrade-accelerator-operator.v0.0.1
  # List of bundle images
  - schema: olm.bundle
    image: quay.io/kenmoini/openshift-upgrade-accelerator-operator-bundle:v0.0.2
  - schema: olm.bundle
    image: quay.io/kenmoini/openshift-upgrade-accelerator-operator-bundle:v0.0.1
```
