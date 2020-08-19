# Emcee Admin

Emcee Admin app allows to track and manage Emcee queue instances.

Current functionality:

- Discover running queues addresses and their versions
- Track worker statuses
- Enable and disable workers
- Kickstarting silent or never started workers
- Basic TeamCity agent manipulation
- Combining Emcee workers and TeamCity agents in a single list

## Building and Running

```shell
$ make app
```

Finder will present you a folder containing `EmceeAdmin.app`. You can launch it from there or move to `/Applications` folder to launch any time e.g. using **Spotlight**.

## Configuration

Currently any configuration is done via CLI.

### Emcee

To add hosts with Emcee queues:

```shell
$ defaults write ru.avito.emceeadmin "hosts" '(host1.com, host2.com)'
```

### TeamCity

To support TeamCity you need to specify URL, username, password, and a list of agent pool ids:

```shell
$ defaults write ru.avito.emceeadmin "teamcityApiEndpoint" 'https://teamcity.example.com'
$ defaults write ru.avito.emceeadmin "teamcityApiUsername" '<rest api username>'
$ defaults write ru.avito.emceeadmin "teamcityApiPassword" '<rest api password>'
$ defaults write ru.avito.emceeadmin "teamcityPoolIds" -array -int <agent pool id> [-int <agent pool id>...]
```

## Screenshots

Menu bar shows all running queues:

![Screenshot of Menu Bar](Images/menubar.png)

When you select a queue from a menu bar, worker management window will be present:

![Queue Information Window](Images/queue_info_window.png)

Select workers and right-click to enable/disable them. 
