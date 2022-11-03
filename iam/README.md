# IAM

## Overview

Gives you centralised control of an AWS account. Is global, that means no concept of region **IAM** at this time. All users, groups, policies, etc are available in all regions. Supports Identity Federation which can be used for Single Sign-on i.e. via SAML. IAM consists of **Users**, **Groups**, **Roles** and **Policy Document**

## Users

By default users have no access to AWS resources. Always set up MFA (Multifactor Authentication) on your root account for more security. There are two ways to access AWS:

* Username/Password: can not be used in the API, they're used in the AWS console
* Access Key ID / Secret Access Key: used in command line, APIs and SDK

## Groups

Are a collection of IAM users, simplifying the assigning of permissions. A user can belong to multiples groups and groups can not belong to another group.

## Roles



## Policy Document

## Secure Token Service

## Exercises

1. Create a group named **developers** with 3 users, assign a police with permissions to list the buckets