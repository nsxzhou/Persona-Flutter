# Image prompt workflow research

## Sources

* ComfyUI Text to Image Workflow: https://docs.comfy.org/tutorials/basic/text-to-image
* Hugging Face Diffusers Text-to-image: https://huggingface.co/docs/diffusers/using-diffusers/conditional_image_generation

## Findings

* ComfyUI models text-to-image as a workflow with positive prompts and negative prompts feeding sampler nodes.
* ComfyUI's beginner guidance recommends English, comma-separated phrases, specific visual descriptions, and separate negative prompts for unwanted qualities.
* Diffusers documents prompt, output size, guidance scale, negative prompt, and seed/generator as separate generation controls.
* This project currently targets GPT/Grok-style image providers and does not expose independent negative prompt, seed, guidance scale, steps, or sampler fields.

## Decision for this task

Implement only the portable prompt layer: use the LLM to create an English positive prompt plus negative constraints, then merge those constraints into the final prompt text. Keep image provider parameters unchanged.
