# Fabro Factory Demo

This repository is a small, readable example of a software factory built with
[Fabro](https://fabro.sh).

## Reference

A local snapshot of the official Fabro documentation is available at
[docs/reference/fabro](docs/reference/fabro/README.md).

## Factory

The factory reads `docs/spec.md`, writes `docs/plan.md`, and implements one
validated plan step at a time.

After writing a specification, run it with:

```sh
fabro run factory
```
