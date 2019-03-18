# Active Server Pages Docker Image

## What is ASP?

Microsoft® Active Server Pages (ASP) is a server-side scripting environment that you can use to create and run dynamic, interactive Web server applications. With ASP, you can combine multiple technologies —Scripting, .NET, NPM, PIP _et cetera_— and languages —VBScript, C#, Javascript, Python _et cetera_— to create interactive Web pages and powerful Web-based applications that are easy to develop and modify.

## What is COM?

The Microsoft® Component Object Model (COM) is a platform-independent, distributed, object-oriented system for creating binary software components that can interact. COM is the foundation technology for Microsoft's OLE (compound documents), ActiveX (Internet-enabled components), as well as others.

COM components dramatically extend the power of ASP. COM components are pieces of compiled code that can be called from ASP pages. COM components are secure, compact, and reusable objects that are compiled as DLLs. They can be written in C#, C++, C, Visual Basic, Delphi, or other languages that support COM.

[Further details about the Component Object Model...](https://docs.microsoft.com/en-us/windows/desktop/com/the-component-object-model)

## Why this project exists?

Despite being born in 1996, Active Server Pages still powers hundreds of millions of applications. It makes sense to have an option to run them on modern container-based infrastructure. Also, this image brings built-in support for using Python as a scripting language.

## How to use this image?

### Testing and Evaluating ideas

```ps
$ md content
$ echo '<%= "Hello World" %>' > .\content\default.asp
$ docker run -it -p 8080:80 -v ${PWD}\content\:C:\inetpub\wwwroot\ --rm --entrypoint powershell nagaozen/asp/windows:1809
```

You can verify the container is running by connecting a browser to the `http://localhost:8080`.

### Deploying in a Continuous Integration & Continuous Deployment (CI/CD) solution

```Dockerfile
FROM nagaozen/asp/windows:1809
COPY content/ .
```

You can then build and run the Docker image:

```ps
$ docker build -t asp-site .
$ docker run -d -p 8000:80 --name my-running-site asp-site
```

There is no need to specify an `ENTRYPOINT` in your Dockerfile since the `nagaozen/asp/windows:1809` base image already includes an entrypoint application that monitors the status of the IIS World Wide Web Publishing Service (W3SVC).

## Q&A

Why is this image based on [Windows base OS container image](https://store.docker.com/images/microsoft-windowsfamily-windows/) instead of [Windows Server Core base OS container image](https://store.docker.com/images/microsoft-windows-servercore/)?

> Our primary goal was to build an imaged based on `mcr.microsoft.com/windows/servercore:ltsc2019` because it's lightweight (4.28GB) when compared to `mcr.microsoft.com/windows:1809` (9.9GB) but to get most of ASP, like _exempli gratia_ Server-Side rendering React (Hooks!) components and npm packages in general, we needed the `htmlfile` control (`CLSID:{25336920-03F9-11cf-8FD0-00AA00686F13}`) which implements `IHTMLDocument2`. It's feasible to build a Virtual Machine and install [Features On Demand](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/features-on-demand-v2--capabilities) to make `mshtml.dll` available, but doing the same procedure inside a container leads to a [bug where FoD only gets `Staged`, never `Installed`](https://github.com/MicrosoftDocs/windows-insider/issues/56).

Why it's running x86 instead of x64?

> After decades of working with ASP, we know that much of its strengths come from being language agnostic. An essential control to work with external scripts in a sandbox manner is `MSScriptControl.ScriptControl` (`CLSID:{0E59F1D5-1FBE-11D0-8FF2-00A0D10038BC}`), but it hasn't been ported to x64. Also, we are aware that [TablacusScriptControl
](https://github.com/tablacus/TablacusScriptControl) exists to fill this gap, but we are fine working inside the 32-bit restrictions in a modern x64 server.

## User Feedback

If you have any issues or concerns, reach out to us through a [GitHub issue](https://github.com/become-evolved/asp-docker/issues/new).
