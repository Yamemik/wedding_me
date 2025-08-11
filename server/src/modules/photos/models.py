from datetime import datetime
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from src.db.base import Base


class Photo(Base):
    __tablename__ = "photos"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    title = Column(String, nullable=True)
    name = Column(String, nullable=True)
    path = Column(String, nullable=False)
    visible = Column(Boolean, default=True, nullable=False)
    
    album_id = Column(Integer, ForeignKey("albums.id", ondelete="CASCADE"), nullable=False)
    album = relationship("Album", back_populates="photos")
    
    tags = relationship("PhotoTag", back_populates="photo", cascade="all, delete")
    comments = relationship("Comment", back_populates="photo", cascade="all, delete")
    likes = relationship("Like", back_populates="photo", cascade="all, delete")
