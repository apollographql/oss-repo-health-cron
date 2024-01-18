# Apollo Clients Team Repository Health Check

This is an experiment in automating some repository health checks we use to gain insights into our respective projects and communities. 💖

Inside of `scripts` you'll find an assortment of bash scripts that are largely project-agnostic (exceptions are noted in the name). These scripts are executed in project-specific GitHub Actions workflows found in `.github/workflows` which checkout the appropriate repository/repositories before executing one or more scripts. All of this is made possible by the excellent [`gh` cli](https://github.com/cli/cli#installation).

## Prior Art

- Our `issues-with-most-emoji-reactions-last-90-days.sh` script was [inspired by one used by the Vercel team](https://github.com/vercel/next.js/blob/6da6388b623087e48393a4603357c673039ddb6f/.github/workflows/issue_popular.yml)
- _<Insert your project here?>_: does your team or a project you love do something similar? PRs to add other open source examples welcome :)
