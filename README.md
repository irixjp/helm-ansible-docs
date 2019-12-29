# Ansible Docs with Helm Interface

## Overview

This is a helm interface for ansible-doc command.
It helps you to develop a playbook.

It works like the below:

![image.gif](image.gif)


## Requirements

Helm


## Installation

Put `helm-ansible-docs.el` into your `load-path` directory.

Write `(require 'helm-ansible-docs)` into your `init.el`


## How to use

Execute `M-x` -> `helm-ansible-docs` or bind your prefer key for the function `ansible-docs`.


## Todo

- add some key binds in helm buffer. ex) `C-c p` -> open browser etc. 
  - but I don't know how to do it ... X(
