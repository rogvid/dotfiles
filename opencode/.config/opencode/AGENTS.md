# Global Agentic Configuration File

## Instructions

This is the main configuration file for agentic coding. The rules set up in this file are the main guidelines for all, but project specific configurations should take precedence.

- Markdown files should include frontmatter metadata to give better context about their purpose and usage. Include at least `name`, `description`. For adding new `skills` or `agents` use the [`agent-resources`](https://github.com/kasperjunge/agent-resources).
- When reading markdown files, start by only reading the frontmatter, then if it is useful, read the entire file. Use bash command line tools like `ripgrep`, `cat`, `find`, and the like to find relevant files and information.
- Use a file based ticketing system for task management. Store tickets under `.ai/tickets/` with frontmatter like `status`, `description`, `title`, `blockers`, `priority`, `created`, `completed`, `depends-on`. 


## Guidelines

### AI Coding

- Always read `AGENTS.md`, `README.md`, `PLAN.md`, `PRD.md`, `TODO.md`, and the `.ai/tickets` folder to understand where the project is going, and what to work on next.
- Always follow a plan -> refine -> implement -> test -> review loop when building use relevant agents, sub-agents, and skills for that, and hand off as much as possible to other agents with only as much context as necessary for doing the work they need to do.
- Before implementing make sure you have a clear idea of how to review your work. For standard backend, cli, or library work tests should be sufficient, but for work that includes some visual elements like TUIs, websites, plots, make sure to use relevant tools to inspect your work like `playwright` for websites, and other tools for other scenarios. When testing visual elements, take screenshots, and store them in `.ai/refs/` prepended with `review_`. Once reviewed, replace `review_` with `rejected_` or `approved_` based on whether the review is approved or not.

### Environments

- Project environments should be handled using [`mise`](https://mise.jdx.dev/)

### Python

- Prefer [`uv`](https://docs.astral.sh/uv/) for python environments and package management and for one-off scripts
- Prefer [`loguru`](https://github.com/Delgan/loguru) for logging
- Prefer [`textual`](https://github.com/Textualize/textual) for writing TUIs

### Web

- Prefer a single styles.css file for website styling unless there is a very good reason not to.
- Prefer a single page html for conceptual prototypes unless there is a very good reason not to.
- Prefer react + tailwindcss for websites unless there is a very good reason not to.
- Prefer using beautiful components from component libraries like [`shadcn`](https://ui.shadcn.com/) over building custom components unless there is a very good reason not to.

### Scripts

- When building scripts to be executed from the command line, prefer bash scripts.
- If the functionality is complex or can't be done in bash prefer python scripts. Always make `uv` scripts (see https://docs.astral.sh/uv/guides/scripts/#declaring-script-dependencies). The main requirements for a `uv` based script is to add something like the following to the top of the script:
```
```bash
#!/usr/bin/env -S uv run --script
# vim: set ft=python:
# -*- mode: python -*-
# language: python
# /// script
# requires-python = ">=3.12"
# dependencies = [
    <add dependencies here/>
# ]
# ///
<add script code after this block/>
```
```
