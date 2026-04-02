# Air Brake Notes

Source: `/home/mrphaot/Downloads/Air Brake Func for 1.9 WIP.pdf`

V1 uses the PDF only as a research aid, not as a canonical contract.

Practical takeaways carried into the controller design:
- braking response is likely nonlinear enough that a learned runtime model is safer than one static brake constant
- a controller should distinguish between nominal cruising control and committed stopping behavior
- future versions can enrich the brake model with train-specific measurements if in-game observations justify it

Not carried into V1 as hard logic:
- any formula that depends on assumptions not directly exposed through the confirmed OC API
