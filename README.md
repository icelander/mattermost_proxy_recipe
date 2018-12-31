# Running Mattermost Behind a Proxy

## Problem

You need to run Mattermost behind an outbound proxy to secure OpenGraph and outgoing webhook connections.

## Solution

**Note:** These instructions are for Ubuntu 16.04

1. Create the file `mattermost.environment` in `/opt/mattermost/config` with these lines. **Note**: Replace the URL of the proxy server with the correct ones for your proxy:

```
HTTP_PROXY=http://127.0.0.1:3128
HTTPS_PROXY=http://127.0.0.1:3128
```



2. Add the `EnvironmentFile` directive to your your `mattermost.service` file, with the value set to `/opt/mattermost/config/mattermost.environment`. See the repository's `mattermost.service` file for more information

```
EnvironmentFile=/opt/mattermost/config/mm.environment
```

3. Run `sudo systemctl daemon-reload`

3. Run `sudo service mattermost restart`

## Discussion

Even though these discussions are for Ubuntu 16.04, they illustrate the general concept behind how to use Mattermost with an outbound proxy. Like all Golang applications, Mattermost respects the Unix environment variables. The only thing you have to do is make sure they're set prior to running the Mattermost application.

Ubuntu, like many Linux variants, uses `systemd` to handle services, and the `EnvironmentFile` directive lets you store them with Mattermost configuration so they can be backed up along with the rest of your Mattermost installation.

Also, since version 3.8 Mattermost has allowed environment variables to override settings in `config.json`. So you can specify any of the options in `config.json` in the `mattermost.environment` file. This is helpful if you want to ensure a production instance of Mattermost cannot connect to unknown database or AD/LDAP servers. More information about this is available [in our documentation](https://docs.mattermost.com/administration/config-settings.html).

This example Vagrant system is running a basic configuration of the Squid proxy, which is a highly configurable proxy server that you can use for everything from web filtering to a reverse proxying load balancer. More information can be found at http://www.squid-cache.org/