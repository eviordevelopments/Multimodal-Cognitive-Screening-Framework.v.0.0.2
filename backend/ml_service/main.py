from fastapi import FastAPI
from api.routes import router as ml_router

app = FastAPI(
    title="MCSF Analytical Engine",
    description="Microservice for Late-Fusion Ensemble Analysis of Multimodal Cognitive Biomarkers",
    version="0.0.2"
)

app.include_router(ml_router, prefix="/api/v1")

@app.get("/health")
def health_check():
    return {"status": "ok", "version": "0.0.2"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
