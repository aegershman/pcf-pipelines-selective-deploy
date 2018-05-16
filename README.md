# pcf-pipelines-selective-deploy

[Please see Project page for backlog of priorities. Especially need to re-implement tile versions being passed from one foundation to the next.](https://github.com/aegershman/pcf-pipelines-selective-deploy/projects/1)

![single-foundation pipeline](_assets/v4.png)

This project is a minimal-compelling product & demonstration of automated selective-deploys for both products and stemcells for a single foundation. New product patch version comes out? Download/stage/selective-deploy it. New stemcell comes out for a product? No problem. Download/upload the latest stemcell, _selectively apply the stemcell to a single product_, then do a selective deploy on *only* that product.

Not only can we take the latest stemcells (previously we just waited until a new tile version came out & it bumped the stemcell for us), we can now selectively deploy those stemcells on a product-by-product basis.

For a single product change-- even something small like newrelic-- it used to take between ~6-20 hours because all the smoke tests & such had to run for each tile. We can now take upgrades, automatically, in as little as 10 minutes. And big changes, like rolling out new version of PAS or stemcells to MySql, still take less time. Minor example: in sandbox we went from PAS 2.1.2 --> 2.1.3 in ~22 minutes.

## disclaimer

**This is experimental**, don't go running it in prod, yadda yadda yadda, **everything is subject to change**, I'm not going to maintain this repo long-term, etc. etc., I take no responsibility for this code totally screwing up your foundation, your life, your marriage, etc.

[Some of the logic used in pipeline tasks requires an unreleased version of `om-linux`; it’s not ready for actual consumption](https://github.com/pivotal-cf/om/issues/158), but hopefully this project demonstrates what can be done. Also huge props to the `om-linux` team. They're making our lives as developers _objectively_ better.

## usage

Go to `foundations/`, fill out a folder with `tiles/` and `params.yml`. Each `product-name.yml` represents, as you might imagine, a product in your foundation. Create a `*.yml` file & fill out the params for the products you want to have the pipeline automatically upgrade. Then run `./set-pipelines <foundation>` to get those pipelines up into Concourse.

(`tiles-jail/` just holds tiles that I don't want to create pipelines for yet. Once you're ready to create a pipeline for it, move the tile into `tiles/`)

## POOL_LOCKS

**Rationale:** In order to prevent individual tile pipelines from trying to install at the same time, we need a mutex on the Opsman. We can _either_ run a poll-wait task (e.g., `wait-opsman-clear` from pcf-pipelines), but there's a number of problems with that. We can now have multiple products/changes staged, and our selective deploys will (should?) only apply changes to certain products. So if we used `wait-opsman-clear`, it would wait for the _entire_ `staged changes` queue to be clear. In this Brave New World™, we only need to poll-wait on running installations. Therefore, we could either write a `wait-opsman-clear`-like task which poll-waits when it sees "`{"error": "installation in progress"}` returned from the Opsman, OR... We could use the [pool-resource](https://github.com/concourse/pool-resource).

Instead of creating a separate repository, we're keeping the "opsman lock" on a separate branch, `POOL_LOCKS`. This branch was created using the following commands:

```bash
git checkout --orphan POOL_LOCKS
git rm --cached -rf .
rm -rf -- *
rm -f .gitignore .gitmodules
git commit --allow-empty -m "initial root commit"
git push origin POOL_LOCKS
```

That creates an empty branch. Then, you just set it up like how they do in the `pool-resource` documentation.

## ideas / concerns

If you've got feedback, questions, concerns, ideas, praise, vitriol, etc., [please create an issue](https://github.com/aegershman/pcf-pipelines-selective-deploy/issues). Any comments are welcome.
