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

An IAM identity that you can create in your account that has specific permissions. An IAM role has some similarities to an IAM user. Roles and users are both AWS identities with permissions policies that determine what the identity can and cannot do in AWS. However, instead of being uniquely associated with one person, a role is intended to be assumable by anyone who needs it. Also, a role does not have standard long-term credentials such as a password or access keys associated with it. Instead, when you assume a role, it provides you with temporary security credentials for your role session.

## Policy Document

IAM is a framework of policies and technologies to ensure that the right users have the appropriate access to technology resources. An AWS IAM policy defines the permissions of an identity (users, groups, and roles) or resource within the AWS account. An AWS IAM policy regulates access to AWS resources to help ensure that only authorized users have access to specific digital assets. Permissions defined within a policy either allow or deny access for the user to perform an action on a specific resource.

**AWS managed policies** is a standalone policy that is created and administered by AWS. Standalone policy means that the policy has its own Amazon Resource Name (ARN) that includes the policy name. AWS managed policies are designed to provide permissions for many common use cases.

**Customer managed policies** You can create standalone policies that you administer in your own AWS account, which we refer to as customer managed policies. You can then attach the policies to multiple principal entities in your AWS account. When you attach a policy to a principal entity, you give the entity the permissions that are defined in the policy.

**Inline policies** is a policy that's embedded in an IAM identity (a user, group, or role). That is, the policy is an inherent part of the identity. You can create a policy and embed it in an identity, either when you create the identity or later.

IAM policies can either be **identity-based** or **resource-based**. 
**Identity-based** policies are attached to an identity (a user, group, or role) and dictate the permissions of that specific identity. In contrast, a **resource-based** policy defines the permissions around the specific resource—by specifying which identities have access to a specific resource and when.

## Permission boundary

A permissions boundary sets the maximum permissions that an identity-based policy can grant to an IAM entity. An entity's permissions boundary allows it to perform only the actions that are allowed by both its identity-based policies and its permissions boundaries.

### Evaluating effective permissions with boundaries

The permissions boundary for an IAM entity (user or role) sets the maximum permissions that the entity can have. This can change the effective permissions for that user or role.

**Identity-based policies with boundaries** – Identity-based policies are inline or managed policies that are attached to a user, group of users, or role. Identity-based policies grant permission to the entity, and permissions boundaries limit those permissions. The effective permissions are the intersection of both policy types. An explicit deny in either of these policies overrides the allow.

![Identity-based policy](./images/permissions_boundary.png)

**Resource-based policies** – Resource-based policies control how the specified principal can access the resource to which the policy is attached.

Within the same account, resource-based policies that grant permissions to an IAM user ARN (that is not a federated user session) are not limited by an implicit deny in an identity-based policy or permissions boundary.

## Secure Token Service

You can use the AWS Security Token Service (AWS STS) to create and provide trusted users with temporary security credentials that can control access to your AWS resources. Temporary security credentials work almost identically to the long-term access key credentials that your IAM users can use, with the following differences:

Temporary security credentials are short-term, as the name implies. They can be configured to last for anywhere from a few minutes to several hours. After the credentials expire, AWS no longer recognizes them or allows any kind of access from API requests made with them.

Temporary security credentials are not stored with the user but are generated dynamically and provided to the user when requested. When (or even before) the temporary security credentials expire, the user can request new credentials, as long as the user requesting them still has permissions to do so.

These differences lead to the following advantages for using temporary credentials:

You do not have to distribute or embed long-term AWS security credentials with an application.

You can provide access to your AWS resources to users without having to define an AWS identity for them. Temporary credentials are the basis for roles and identity federation.

The temporary security credentials have a limited lifetime, so you do not have to rotate them or explicitly revoke them when they're no longer needed. After temporary security credentials expire, they cannot be reused. You can specify how long the credentials are valid, up to a maximum limit.

## Exercises

1. Create a group named **developers** with 3 users, assign a police with permissions to list the buckets