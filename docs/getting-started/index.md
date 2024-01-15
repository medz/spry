---
title: Getting Started → Introduction
---

# Introduction

Welcome to the Spry documentation! Spry is a web framework for Dart that allows you to write backends, web application APIs, and HTTP servers in Dart. Spry is written in Dart, a modern, powerful, and secure language that offers many advantages over more traditional server languages.

If you encounter any problems during use, please submit them in [HitHub Discussions](https://github.com/medz/spry/discussions).

[[toc]]

## Why Spry?

Spry has **magic**, lightweight APIs design, using the classes you are familiar with in `dart:io`, you have no learning burden!

## Performance

In various frameworks, they always use strange ways to match routes, and one of the common ways is regular expressions. In Spry, thanks to the Trie tree route matching of [RoutingKit](https://pub.dev/packages/routingkit), the performance has been greatly improved.

## Hard to catch errors

When the application is running, if an abnormal error occurs. Usually you have to set up a `try/catch` to capture, and then you handle it in the corresponding `catch`. There is no way to do it more elegantly.

In Spry, the **Exception filters** mechanism is designed. You only need to inject the exception filters you need to catch exception errors during application running, and then you can handle them in a more elegant way.

## Elegant Magic

When you decide to use a web framework, you need to learn a variety of new APIs and concepts. You need to follow all kinds of unique rules, even request/response is dialect!

In Spry, you don’t need to learn any new APIs, you just need to use the classes in dart:io that you are familiar with, and you can start your development journey. At the same time, Spry injects a lot of magic into request/response in `dart:io` to make your development easier.
