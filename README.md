# OpenShift Operator Catalog

> Operators, by yours truly

## Included Operators

- OpenShift Upgrade Accelerator Operator

## Deploy the Operator Catalog

```bash
# Bleeding Edge
oc apply -k https://github.com/kenmoini/openshift-operator-catalog/deploy/overlays/main/

# Less blood
oc apply -k https://github.com/kenmoini/openshift-operator-catalog/deploy/overlays/stable/
```

## Adding Operators to the Catalog

As long as your bundles are pushed and published, all that you need to do to add an Operator Bundle to this Catalog is add it to the `bundles/` directory in a YAML file.

Once the changes are merged into either the main or stable branches, is a semver tag that starts with `v*` the GitHub Actions workflows will build the operator catalog and push.

The GitHub Actions will validate the files and add them to the Catalog.

The name can be anything, though it's suggested to be the name of your Operator - either `yml` or `yaml` extensions will work.

The format of the file is simple:

```yaml
---
name: openshift-upgrade-accelerator-operator
bundles:
  - version: "main"
    image: quay.io/kenmoini/openshift-upgrade-accelerator-operator-bundle:main
  - version: "0.0.1"
    image: quay.io/kenmoini/openshift-upgrade-accelerator-operator-bundle:v0.0.1
  - version: "0.0.1"
    image: quay.io/kenmoini/openshift-upgrade-accelerator-operator-bundle:v0.0.1
```
