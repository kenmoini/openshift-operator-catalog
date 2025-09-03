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