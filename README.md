# dbatools templates
Want to join in on the fun? Here are some templates to help you get started.

<p align="center"><img src=https://blog.netnerds.net/wp-content/uploads/2016/05/dbatools.png></p>

Before you begin..
--------------

Please check out the [Join Us page on dbatools.io](https://dbatools.io/join-us/). The [Guidelines](https://dbatools.io/join-us/guidelines/) are **super important**, especially the part that's titled "This is important" because it talks about how to easily add your template to your dbatools development environment.

We're also on Slack
--------------
A number of us are on the <a href="https://sqlcommunity.slack.com">SQL Server Community Slack</a> in the #dbatools channel. Need an invite? Check out the <a href="https://dbatools.io/slack/">self-invite page</a>.

Using Plaster to get started
--------------

In order to speed up developing your cmdlet you may use the plaster template included in this repo.

`Install-Module Plaster`
`Invoke-Plaster -TemplatePath C:\code\dbatools-templates\plaster\ -DestinationPath C:\code\dbatools\`
Answer the Questions, or hit enter for the defaults
```
The action this cmdlet will take (Verb without dash): Test
The element this cmdlet will interact with (Noun without dba or dash): Something
Who is authoring this function (Git Name):
What is your Twitter Handle (without @): psdbatools
If your creating a function, where will this be used:
[E] External  [I] Internal  [?] Help (default is "E"): E
```